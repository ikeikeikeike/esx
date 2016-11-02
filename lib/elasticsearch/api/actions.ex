defmodule Elasticsearch.API.Actions do
  import Elasticsearch.API.R

  alias Elasticsearch.API.Utils
  alias Elasticsearch.Transport.Client

  def index(%Client{} = ts, %{} = args) when map_size(args) < 2,
   do: {:error, "Required argument 'index or type' missing"}
  def index(%Client{} = ts, %{type: type}) when not is_bitstring(type),
   do: {:error, "Required argument 'index' missing"}
  def index(%Client{} = ts, %{index: index}) when not is_bitstring(index),
   do: {:error, "Required argument 'type' missing"}
  def index(%Client{} = ts, args) do
    method = if args[:id], do: "PUT", else: "POST"
    path   = Utils.pathify [Utils.escape(args[:index]), Utils.escape(args[:type]), Utils.escape(args[:id])]
    params = %{}
    body   = args[:body]

    Client.perform_request(ts, method, path, params, body)
    |> response
  end

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

    case Client.perform_request(ts, method, path, params, body) do
      {:ok, rs} ->
        rs.status_code == 200
      {:error, err} ->
        case err do
          %HTTPoison.Error{reason: :econnrefused} ->
            false
          _ ->
            {:error, err}
        end
    end
  end
  def ping!(%Client{} = ts, _args \\ %{}) do
    case ping(ts) do
      rs when is_boolean(rs) ->
        rs
      {:error, err} ->
        raise err
    end
  end

end
