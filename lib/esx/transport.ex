defmodule ESx.Transport do
  @moduledoc "ESx.Transport"

  use ESx.Transport.Config

  defmodule State do
    @moduledoc "State"

    use ESx.Transport.Statex, [
      :last_request_at, :resurrect_after,
      :counter, :reload_after, :reload,
      :randomize_hosts,
      :max_retries,
      :retry_on_status,
    ]
    def initialize_state(args) do
      Keyword.merge args, [
        max_retries: 5,
        retry_on_status: [],
        randomize_hosts: false,
        last_request_at: :os.system_time(:seconds),
        resurrect_after: 60,
        reload_after: 10_000,
        reload: true,
        counter: 0,
      ]
    end
  end

  import ESx.Checks, only: [present?: 1]

  require Logger

  alias ESx.Transport.{State, Sniffer, Connection}

  defstruct [
    method: "GET",
    conn: nil,
    trace: false,
  ]

  @type t :: %__MODULE__{}

  def transport, do: transport defconfig
  def transport(args) do
    Connection.start_conn args
    struct __MODULE__, Keyword.merge(args, conn: conn)
  end

  def conn do
    s = State.state

    if :os.system_time(:seconds) > s.last_request_at + s.resurrect_after do
      resurrect_deads
    end

    counter = State.incr_state! :counter, 1

    if s.reload && rem(counter, s.reload_after) == 0 do
      rebuild_conns
      Connection.conn
    else
      Connection.conn
    end
  end

  def rebuild_conns do
    urls = Sniffer.urls transport

    old_conns = Connection.conns
    new_conns =
      urls
      |> Enum.map(&Connection.start_conn/1)
      |> Enum.map(fn
        {:error, {_, pid}} when is_pid(pid) ->
          Connection.state pid
        {:ok, pid} ->
          Connection.state pid
        _ ->
          nil
      end)
      |> Enum.filter(& !!&1)

    stale_conns = old_conns -- new_conns
    Enum.each stale_conns, & Connection.delete &1.url
  end

  def resurrect_deads do
    Connection.conns
    |> Enum.filter_map(& &1.dead, &Connection.resurrect!/1)
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

    do_perform_request method, path, params, body
  end
  def perform_request!(%__MODULE__{} = ts, method, path, params \\ %{}, body \\ nil) do
    case perform_request(ts, method, path, params, body) do
      {:ok, rsp} -> rsp
      {:error, err} -> raise err
    end
  end

  defmodule ServerError do
    defexception message: "no message"
  end

  defp do_perform_request(method, path, params, body, tries \\ 0) do
    tries = tries + 1

    c = conn()  # TODO: needs error management

    headers = [{"Content-Type", "application/json"}, {"Connection", "keep-alive"}]
    options = [hackney: [pool: c.pidname]]
    uri =
      c.url
      |> URI.merge(path)
      |> URI.merge("?" <> URI.encode_query params)
      |> URI.to_string

    resp =
      case method do
        "GET"    -> c.client.request :get,    uri, body, headers, options
        "PUT"    -> c.client.request :put,    uri, body, headers, options
        "POST"   -> c.client.request :post,   uri, body, headers, options
        "HEAD"   -> c.client.request :head,   uri, body, headers, options
        "DELETE" -> c.client.request :delete, uri, body, headers, options
        method   -> {:error, %ArgumentError{message: "Method #{method} not supported"}}
      end

    s = State.state

    case resp do
      {:ok, %HTTPoison.Response{status_code: code} = resp} when code < 300 ->
        resp

        # TODO:
        # if ts.trace, do: traceout method, uri, body

        # connection.healthy! if connection.failures > 0

      # retry_on_status
      {:ok, %HTTPoison.Response{status_code: code}} when code >= 300 ->
        if tries <= s.max_retry and code in s.retry_on_status do
          Logger.debug "retry in #{code} status code."
          do_perform_request method, path, params, body, tries
        else
          {:error, %ServerError{message: "Method #{method} not supported"}}
        end

      # failure
      {:error, %HTTPoison.Error{reason: reason} = perr} ->
        if tries <= s.max_retry do
          Logger.debug reason
          do_perform_request method, path, params, body, tries
        else
          {:error, perr}
        end
    end
  end

  defp traceout(out) when is_binary(out) do
    Logger.debug out
  end
  defp traceout(method, uri, "") do
    traceout "curl -X #{method} '#{uri}'\n"
  end
  defp traceout(method, uri, body) when is_binary(body) do
    case JSX.prettify(body) do
      {:ok, pretitfied} ->
        traceout "curl -X #{method} '#{uri}' -d '#{pretitfied}'\n"
      {:error, message} ->
        traceout "curl -X #{method} '#{uri}' -d '#### couldn't prettify body ####'\n"
    end
  end

end
