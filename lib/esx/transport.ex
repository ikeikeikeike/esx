defmodule ESx.Transport do
  defstruct [
    url: "http://127.0.0.1:9200",
    transport: HTTPoison, # TODO: More
    method: "GET",
    trace: true,
  ]

  # @type t :: %__MODULE__{method: String.t, transport: HTTPoison.t, trace: String.t}

  def transport(args \\ %{}) do
    struct %__MODULE__{}, args
  end

  def perform_request(%__MODULE__{} = ts, method, path, params \\ %{}, body \\ nil) do
    method = if "GET" == method && body, do: ts.method, else: method
    headers = [{"content-type", "application/json"}]
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
      "GET"    -> ts.transport.request :get,    uri, body, headers
      "PUT"    -> ts.transport.request :put,    uri, body, headers
      "POST"   -> ts.transport.request :post,   uri, body, headers
      "HEAD"   -> ts.transport.request :head,   uri, body, headers
      "DELETE" -> ts.transport.request :delete, uri, body, headers
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
