defmodule ESx.Transport do
  import ESx.Checks, only: [blank?: 1]

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
    if "GET" == method && body, do: method = ts.method

    uri = URI.merge(ts.url, path) |> URI.to_string
    body = if body, do: Poison.encode!(body), else: ""
    headers = [{"content-type", "application/json"}]

    if ts.trace do
      out = "curl -X #{method} '#{uri}'"
      unless blank?(body), do: out = "#{out} -d '#{JSX.prettify! body}'"
      IO.puts "#{out}\n"
    end

    case method do
      "GET"    -> ts.transport.request :get,    uri, body, headers
      "PUT"    -> ts.transport.request :put,    uri, body, headers
      "POST"   -> ts.transport.request :post,   uri, body, headers
      "HEAD"   -> ts.transport.request :head,   uri, body, headers
      "DELETE" -> ts.transport.request :delete, uri, body, headers
      _        -> {:error, %ArgumentError{message: "Method #{method} not supported"}}
    end
  end
  def perform_request!(%__MODULE__{} = ts, method, path, params \\ %{}, body \\ nil) do
    case perform_request(ts, method, path, params, body) do
      {:ok, rs} -> rs
      {:error, err} -> raise err
    end
  end

end
