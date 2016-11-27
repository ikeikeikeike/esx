defmodule ESx.Transport do
  use ESx.Transport.Config

  defmodule State do
    use ESx.Transport.Statex, [
      :last_request_at, :resurrect_after,
      :counter, :reload_after, :reload,
      :randomize_hosts
    ]
    def initialize_state(args) do
      Keyword.merge args, [
        randomize_hosts: false,
        last_request_at: :os.system_time(:seconds),
        resurrect_after: 60,
        reload_after: 10_000,
        reload: true,
        counter: 0,
      ]
    end
  end

  alias ESx.Transport.State
  alias ESx.Transport.Sniffer
  alias ESx.Transport.Connection

  import ESx.Checks, only: [present?: 1]

  require Logger

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

  defp conn do
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

  # TODO: Count dead connection
  #
  def perform_request(%__MODULE__{} = ts, method, path, params \\ %{}, body \\ nil) do
    method = if "GET" == method && body, do: ts.method, else: method

    headers = [{"Content-Type", "application/json"}, {"Connection", "keep-alive"}]
    options = [hackney: [pool: ts.conn.pidname]]

    uri =
      URI.merge(ts.conn.url, path)
      |> URI.merge("?" <> URI.encode_query params)
      |> URI.to_string
    body =
      case body do
        body when is_map(body) ->
          Poison.encode!(body)
        body ->
          body || ""
      end

    if ts.trace, do: traceout method, uri, body

    case method do
      "GET"    -> ts.conn.client.request :get,    uri, body, headers, options
      "PUT"    -> ts.conn.client.request :put,    uri, body, headers, options
      "POST"   -> ts.conn.client.request :post,   uri, body, headers, options
      "HEAD"   -> ts.conn.client.request :head,   uri, body, headers, options
      "DELETE" -> ts.conn.client.request :delete, uri, body, headers, options
      method   -> {:error, %ArgumentError{message: "Method #{method} not supported"}}
    end
  end
  def perform_request!(%__MODULE__{} = ts, method, path, params \\ %{}, body \\ nil) do
    case perform_request(ts, method, path, params, body) do
      {:ok, rsp} -> rsp
      {:error, err} -> raise err
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
