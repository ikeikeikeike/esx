defmodule ESx.API.Indices do
  import ESx.API.R

  alias ESx.API.Utils
  alias ESx.Transport

  def delete(ts, args \\ %{}) do
    method = "DELETE"
    path   = Utils.pathify Utils.listify(args[:index])
    params = %{}
    body   = nil

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def exists(ts, args \\ %{}) do
    method = "HEAD"
    path   = Utils.listify(args[:index])
    params = %{}
    body   = nil

    status200? ts, method, path, params, body
  end

  defdelegate exists?(ts, args \\ %{}), to: __MODULE__, as: :exists

  def create(ts, %{index: index, body: body}) when is_map(body) do
    method = "PUT"
    path   = Utils.pathify [Utils.escape(index)]
    params = %{}
    body   = body

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def get_alias(ts, args \\ %{}) do
    method = "GET"
    path   = Utils.pathify [Utils.listify(args[:index]), '_alias', Utils.escape(args[:name])]
    params = %{}
    body   = nil

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def get_aliases(ts, args \\ %{}) do
    method = "GET"
    path   = Utils.pathify [Utils.listify(args[:index]), '_aliases', Utils.listify(args[:name])]
    params = %{}
    body   = nil

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def update_aliases(ts, %{body: body}) when is_map(body) do
    method = "POST"
    path   = "_aliases"
    params = %{}

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def put_alias(ts, %{name: name} = args) do
    method = "PUT"
    path   = Utils.pathify [Utils.listify(args[:index]), '_alias', Utils.escape(name)]
    params = %{}
    body   = args[:body]

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def delete_alias(ts, %{index: index, name: name}) do
    method = "DELETE"
    path   = Utils.pathify [Utils.listify(index), '_alias', Utils.escape(name)]
    params = %{}
    body   = nil

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def exists_alias(ts, args \\ %{}) do
    method = "HEAD"
    path   = Utils.pathify [Utils.listify(args[:index]), '_alias', Utils.escape(args[:name])]
    params = %{}
    body   = nil

    status200? ts, method, path, params, body
  end

  defdelegate exists_alias?(ts, args \\ %{}), to: __MODULE__, as: :exists_alias

end
