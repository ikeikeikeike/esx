defmodule Elasticsearch.API.R do
  alias Elasticsearch.Transport.Client

  @blank_args {"GET", "", %{}, nil}
  def blank_args, do: @blank_args

  def response({:ok, rs}), do: Poison.decode rs.body
  def response({:error, err}), do: {:error, err}

  def response!({:ok, rs}), do: rs
  def response!({:error, err}), do: raise err

  def status200?(%Client{} = ts, method, path, params \\ %{}, body \\ nil) do
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

  def required(_mod, _func, %Client{} = ts, %{} = args) when map_size(args) < 2,
   do: {:error, "Required argument 'index or type' missing"}
  def required(_mod, _func, %Client{} = ts, %{type: type}) when not is_bitstring(type),
   do: {:error, "Required argument 'index' missing"}
  def required(_mod, _func, %Client{} = ts, %{index: index}) when not is_bitstring(index),
   do: {:error, "Required argument 'type' missing"}
  def required(mod, func, %Client{} = ts, %{} = args),
   do: apply mod, func, [ts, Map.merge(args, %{required: true})]

end
