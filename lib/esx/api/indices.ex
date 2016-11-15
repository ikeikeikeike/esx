defmodule ESx.API.Indices do
  import ESx.API.R

  alias ESx.API.Utils
  alias ESx.Transport

  def delete(%Transport{} = ts, args \\ %{}) do
    method = "DELETE"
    path   = Utils.pathify Utils.listify(args[:index])
    params = %{}
    body   = nil

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def delete_alias(%Transport{} = ts, %{index: index, name: name}) do
    method = "DELETE"
    path   = Utils.pathify [Utils.listify(index), '_alias', Utils.escape(name)]
    params = %{}
    body   = nil

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def exists(%Transport{} = ts, args \\ %{}) do
    method = "HEAD"
    path   = Utils.listify(args[:index])
    params = %{}
    body   = nil

    status200? ts, method, path, params, body
  end

  defdelegate exists?(ts, args \\ %{}), to: __MODULE__, as: :exists

  def exists_alias(%Transport{} = ts, args \\ %{}) do
    method = "HEAD"
    path   = Utils.pathify [Utils.listify(args[:index]), '_alias', Utils.escape(args[:name])]
    params = %{}
    body   = nil

    status200? ts, method, path, params, body
  end

  defdelegate exists_alias?(ts, args \\ %{}), to: __MODULE__, as: :exists_alias

  def create(ts, %{index: index, body: body}) when is_map(body) do
    method = "PUT"
    path   = Utils.pathify [Utils.escape(index)]
    params = %{}
    body   = body

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

end
