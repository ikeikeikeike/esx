defmodule Elasticsearch.API.Actions do
  alias Elasticsearch.API.Utils
  alias Elasticsearch.Transport.Client

  def info(%Client{} = ts, _args \\ []) do
    {method, path, params, body} = @blank_args

    Client.perform_request(ts, method, path, params, body)
    |> response
  end
  def info!(%Client{} = ts, _args \\ []) do
    info(ts)
    |> response!
  end

  def ping(%Client{} = ts, _args \\ []) do
    {method, path, params, body} = @blank_args

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
  def ping!(%Client{} = ts, _args \\ []) do
    case ping(ts) do
      rs when is_boolean(rs) ->
        rs
      {:error, err} ->
        raise err
    end
  end

  def search(%Client{} = ts, args \\ []) do
    if ! args[:index] && args[:type], do: args = Keyword.put :index, "_all"

    method = "GET"
    path   = Utils.pathify([Utils.listify(args[:index]), Utils.listify(args[:type]), "_search"])
    params = []
    body   = args[:body]

    Client.perform_request(ts, method, path, params, body)
    |> response
  end
  def search!(%Client{} = ts, args \\ []) do
    search(ts, args)
    |> response!
  end

  @blank_args {"GET", "", [], nil}

  defp response({:ok, rs}), do: Poison.decode rs.body
  defp response({:error, err}), do: {:error, err}

  defp response!({:ok, rs}), do: rs
  defp response!({:error, err}), do: raise err

end
