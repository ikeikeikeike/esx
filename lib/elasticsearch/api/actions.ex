defmodule Elasticsearch.API.Actions do
  import Elasticsearch.API.R

  alias Elasticsearch.API.Utils
  alias Elasticsearch.Transport.Client

  def info(%Client{} = ts, _args \\ %{}) do
    {method, path, params, body} = blank_args

    Client.perform_request(ts, method, path, params, body)
    |> response
  end
  def info!(%Client{} = ts, _args \\ %{}) do
    info(ts)
    |> response!
  end

  def ping(%Client{} = ts, _args \\ %{}) do
    {method, path, params, body} = blank_args

    status200? ts, method, path, params, body
  end

  def ping!(%Client{} = ts, _args \\ %{}) do
    case ping(ts) do
      rs when is_boolean(rs) ->
        rs
      {:error, err} ->
        raise err
    end
  end

  def index(%Client{} = ts, %{required: true} = args) do
    method = if args[:id], do: "PUT", else: "POST"
    path   = Utils.pathify [Utils.escape(args[:index]), Utils.escape(args[:type]), Utils.escape(args[:id])]
    params = %{}
    body   = args[:body]

    Client.perform_request(ts, method, path, params, body)
    |> response
  end
  def index(%Client{} = ts, args),
    do: required __MODULE__, :index, %Client{} = ts, args

  def search(%Client{} = ts, args \\ %{}) do
    if ! args[:index] && args[:type], do: args = Keyword.put :index, "_all"

    method = "GET"
    path   = Utils.pathify([Utils.listify(args[:index]), Utils.listify(args[:type]), "_search"])
    params = %{}
    body   = args[:body]

    Client.perform_request(ts, method, path, params, body)
    |> response
  end

  def search!(%Client{} = ts, args \\ %{}) do
    search(ts, args)
    |> response!
  end

end
