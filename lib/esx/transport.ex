defmodule ESx.Transport do
  defmodule State do
    use ESx.Transport.Statex, [
      :last_request_at, :resurrect_after,
      :counter, :reload_after, :reload_connections,
      :randomize_hosts
    ]
    def initialize_state(args) do
      Keyword.merge args, [
        last_request_at: :os.system_time(:seconds),
        resurrect_after: 60,
        counter: 0,
        reload_after: 10_000,
        reload_connections: true,
        randomize_hosts: false,
      ]
    end
  end

  import ESx.Checks, only: [present?: 1, blank?: 1]
  alias ESx.Transport.State
  alias ESx.Transport.Sniffer
  alias ESx.Transport.Collection
  alias ESx.Transport.Connection

  defstruct [
    method: "GET",
    trace: false,
  ]

  @type t :: %__MODULE__{}

  def transport(args \\ []) do
    if present?(args), do: Connection.pool args
    struct __MODULE__, args
  end

  def pool do
    s = State.state

    if Time.now > s.last_request_at + s.resurrect_after do
      resurrect_deads!
    end

    counter = State.incr_state! :counter, 1

    if s.reload_connections && rem(counter, s.reload_after) == 0 do
      # reload_connections!
    end

    Collection.pool
  end

  def reload_connections! do
    # urls = Sniffer.urls transport
    # rebuild_connections :hosts => hosts, :options => options
  end

  def resurrect_deads! do
    Connection.pools
    |> Enum.filter_map(& &1.dead, &Connection.resurrect!/1)
  end

  def perform_request(%__MODULE__{} = ts, method, path, params \\ %{}, body \\ nil) do
    method = if "GET" == method && body, do: ts.method, else: method

    headers = [{"Content-Type", "application/json"}, {"Connection", "keep-alive"}]
    options = [hackney: [pool: Base.encode16(:erlang.md5(ts.url), case: :lower)]] # TODO: transfer to connection module

    uri =
      URI.merge(ts.url, path)
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
      "GET"    -> ts.transport.request :get,    uri, body, headers, options
      "PUT"    -> ts.transport.request :put,    uri, body, headers, options
      "POST"   -> ts.transport.request :post,   uri, body, headers, options
      "HEAD"   -> ts.transport.request :head,   uri, body, headers, options
      "DELETE" -> ts.transport.request :delete, uri, body, headers, options
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
    IO.puts out
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
