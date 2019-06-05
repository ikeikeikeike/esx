defmodule ESx.Transport do
  @moduledoc "ESx.Transport"

  use ESx.Transport.Config

  import ESx.Checks, only: [present?: 1]

  defmodule State do
    @moduledoc "State"

    use ESx.Transport.Statex, [
      :last_request_at,
      :resurrect_after,
      :counter,
      :reload_after,
      :reload,
      :randomize_hosts,
      :max_retries,
      :retry_on_status,
      :reload_on_failure,
      :retry_on_failure
    ]

    def initialize_state(args) do
      Keyword.merge(
        args,
        max_retries: 5,
        retry_on_status: [],
        reload_on_failure: false,
        retry_on_failure: false,
        randomize_hosts: false,
        last_request_at: :os.system_time(:seconds),
        resurrect_after: 60,
        reload_after: 10_000,
        reload: true,
        counter: 0
      )
    end
  end

  require Logger

  alias ESx.Funcs
  alias ESx.Transport.{State, Sniffer, Connection, ServerError, UnknownError}

  defstruct method: "GET", path: "", params: %{}, body: nil, trace: false

  @type t :: %__MODULE__{}

  def transport do
    case Connection.alives() do
      alives when 0 < length(alives) ->
        alives
        |> Enum.random()
        |> Map.delete(:__struct__)
        |> Enum.into([])
        |> transport()

      _ ->
        transport(defconfig())
    end
  end

  def transport(args) do
    {_, arg} = Keyword.pop(args, :url)

    Connection.start_conn(Funcs.build_url!(args) ++ arg)
    struct(__MODULE__, args)
  end

  def conn do
    s = State.state()

    if :os.system_time(:seconds) > s.last_request_at + s.resurrect_after do
      resurrect_deads()
    end

    counter = State.incr_state!(:counter, 1)

    if (s.reload and rem(counter, s.reload_after) == 0) or counter == 1 do
      rebuild_conns()
    end

    Connection.conn()
  end

  def rebuild_conns do
    cnfs = Sniffer.urls(transport())

    if is_list(cnfs) and length(cnfs) > 0 do
      old_conns = Connection.checkout()

      new_conns =
        cnfs
        |> Enum.map(&Connection.start_conn/1)
        |> Enum.zip(cnfs)
        |> Enum.map(fn
          {{:error, {_, pid}}, cnf} when is_pid(pid) ->
            Connection.state(cnf[:url])

          {{:ok, pid}, _} when is_pid(pid) ->
            Connection.checkout(pid)

          _ ->
            nil
        end)
        |> Enum.filter(&(!!&1))

      stale_conns = old_conns -- new_conns
      Enum.each(stale_conns, &Connection.delete/1)

      new_conns
      |> Enum.map(&Connection.alive!/1)
      |> Enum.each(&Connection.checkin/1)
    end
  end

  def resurrect_deads do
    Connection.conns()
    |> Enum.filter(& &1.dead)
    |> Enum.map(&Connection.resurrect!/1)
  end

  def perform_request(%__MODULE__{} = ts) do
    perform_request(ts, ts.method, ts.path, ts.params, ts.body)
  end

  def perform_request(%__MODULE__{} = ts, method, path, params \\ %{}, body \\ nil) do
    method = if "GET" == method && body, do: ts.method, else: method

    body =
      case body do
        body when is_map(body) ->
          Poison.encode!(body)

        body ->
          body || ""
      end

    do_perform_request(struct(ts, method: method, path: path, params: params, body: body))
  end

  def perform_request!(%__MODULE__{} = ts) do
    perform_request!(ts, ts.method, ts.path, ts.params, ts.body)
  end

  def perform_request!(%__MODULE__{} = ts, method, path, params \\ %{}, body \\ nil) do
    case perform_request(ts, method, path, params, body) do
      {:ok, rsp} -> rsp
      {:error, err} -> raise err
    end
  end

  defp do_perform_request(%__MODULE__{} = ts, tries \\ 0) do
    cn = Connection.checkout(conn())
    tries = tries + 1

    headers = [{"Content-Type", "application/json"}, {"Connection", "keep-alive"}]
    options = [hackney: [pool: cn.pidname]]

    url =
      cn.url
      |> Funcs.merge(ts.path)
      |> Funcs.merge(if present?(ts.params), do: "?" <> URI.encode_query(ts.params), else: "")
      |> URI.to_string()

    if ts.trace and tries == 1, do: traceout(ts.method, url, ts.body)

    resp =
      case ts.method do
        "GET" -> cn.client.request(:get, url, ts.body, headers, options)
        "PUT" -> cn.client.request(:put, url, ts.body, headers, options)
        "POST" -> cn.client.request(:post, url, ts.body, headers, options)
        "HEAD" -> cn.client.request(:head, url, ts.body, headers, options)
        "DELETE" -> cn.client.request(:delete, url, ts.body, headers, options)
        method -> {:error, %ArgumentError{message: "Method #{method} not supported"}}
      end

    s = State.state()

    try do
      case resp do
        {:ok, %HTTPoison.Response{status_code: status}} when status < 300 ->
          if cn.failures > 0, do: Connection.healthy!(cn)

          resp

        {:ok, %HTTPoison.Response{status_code: status, body: rbody} = resp} when status >= 300 ->
          if cn.failures > 0, do: Connection.healthy!(cn)

          if tries <= s.max_retries and status in s.retry_on_status do
            Logger.warn(
              "[retry_on_status] Retries #{tries}/#{s.max_retries} " <> "connecting to #{url}"
            )

            do_perform_request(ts, tries)
          else
            msg =
              "[#{status}] Couldn't get response from #{url} after " <> "#{tries} tries: #{rbody}"

            Logger.warn(msg)
            {:error, ServerError.wrap(response: resp, status: status, message: msg)}
          end

        # Failure
        {:error, %HTTPoison.Error{reason: reason} = error} ->
          Logger.error("Close connection to #{url}: #{reason}")
          Connection.dead!(cn)

          cond do
            s.reload_on_failure and tries < length(Connection.conns()) ->
              Logger.warn(
                "[reload_on_failure] Reloading connections " <>
                  "(retries #{tries}/#{length(Connection.conns())})"
              )

              rebuild_conns()

              do_perform_request(ts, tries)

            s.retry_on_failure and tries <= s.max_retries ->
              Logger.warn(
                "[retry_on_failure] Retries #{tries}/#{s.max_retries} " <> "connecting to #{url}"
              )

              do_perform_request(ts, tries)

            true ->
              {:error, error}
          end

        error ->
          msg = "[unknown] url:#{url} tries:#{tries}"
          Logger.error(msg)

          {:error, UnknownError.wrap(error: error, message: msg)}
      end
    catch
      :exit, errors ->
        error = elem(errors, 0)
        Logger.error("Close connection: #{inspect(errors)}")

        {:error, error}
    after
      Connection.checkin(cn)
    end
  end

  defp traceout(out) when is_binary(out) do
    Logger.debug(out)
  end

  defp traceout(method, url, "") do
    traceout("curl -X #{method} '#{url}'\n")
  end

  defp traceout(method, url, body) when is_binary(body) do
    case JSX.prettify(body) do
      {:ok, pretitfied} ->
        traceout("curl -X #{method} '#{url}' -d '#{pretitfied}'\n")

      {:error, _message} ->
        traceout("curl -X #{method} '#{url}' -d '#### couldn't prettify body ####'\n")
    end
  end
end
