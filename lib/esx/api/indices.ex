defmodule ESx.API.Indices do
  import ESx.API.R

  alias ESx.API.Utils
  alias ESx.Transport

  def delete(ts, args \\ %{}) do
    method = "DELETE"
    path   = Utils.pathify Utils.listify(args[:index])
    params = Utils.extract_params args
    body   = nil

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def exists(ts, args \\ %{}) do
    method = "HEAD"
    path   = Utils.listify(args[:index])
    params = Utils.extract_params args
    body   = nil

    status200? ts, method, path, params, body
  end

  defdelegate exists?(ts, args \\ %{}), to: __MODULE__, as: :exists

  def create(ts, %{index: index, body: body} = args) when is_map(body) do
    method = "PUT"
    path   = Utils.pathify [Utils.escape(index)]
    params = Utils.extract_params args
    body   = body

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def get_alias(ts, args \\ %{}) do
    method = "GET"
    path   = Utils.pathify [Utils.listify(args[:index]), "_alias", Utils.escape(args[:name])]
    params = Utils.extract_params args
    body   = nil

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def get_aliases(ts, args \\ %{}) do
    method = "GET"
    path   = Utils.pathify [Utils.listify(args[:index]), "_aliases", Utils.listify(args[:name])]
    params = Utils.extract_params args
    body   = nil

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def update_aliases(ts, %{body: body} = args) when is_map(body) do
    method = "POST"
    path   = "_aliases"
    params = Utils.extract_params args

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def put_alias(ts, %{name: name} = args) do
    method = "PUT"
    path   = Utils.pathify [Utils.listify(args[:index]), "_alias", Utils.escape(name)]
    params = Utils.extract_params args
    body   = args[:body]

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def delete_alias(ts, %{index: index, name: name} = args) do
    method = "DELETE"
    path   = Utils.pathify [Utils.listify(index), "_alias", Utils.escape(name)]
    params = Utils.extract_params args
    body   = nil

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def exists_alias(ts, args \\ %{}) do
    method = "HEAD"
    path   = Utils.pathify [Utils.listify(args[:index]), "_alias", Utils.escape(args[:name])]
    params = Utils.extract_params args
    body   = nil

    status200? ts, method, path, params, body
  end

  defdelegate exists_alias?(ts, args \\ %{}), to: __MODULE__, as: :exists_alias

  def refresh(ts, args \\ %{}) do
    method = "POST"
    path   = Utils.pathify [Utils.listify(args[:index]), "_refresh"]
    params = Utils.extract_params args
    body   = nil

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def get_mapping(ts, args \\ %{}) do
    method = "GET"
    path   = Utils.pathify [Utils.listify(args[:index]), "_mapping", Utils.listify(args[:type])]
    params = Utils.extract_params args
    body = nil

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def get_settings(ts, args \\ %{}) do
    method = "GET"
    path   = Utils.pathify [Utils.listify(args[:index]), Utils.listify(args[:type]), args.delete(:prefix), "_settings", Utils.escape(args[:name])]
    params = Utils.extract_params args
    body   = nil

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def get_template(ts, args \\ %{}) do
    method = "GET"
    path   = Utils.pathify ["_template", Utils.escape(args[:name])]
    params = Utils.extract_params args
    body   = args[:body]

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def put_template(ts, %{name: name, body: body} = args) do
    method = "PUT"
    path   = Utils.pathify "_template", Utils.escape(name)
    params = Utils.extract_params args
    body   = body

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def delete_template(ts, %{name: name} = args) do
    method = HTTP_DELETE
    path   = Utils.pathify "_template", Utils.escape(name)
    params = Utils.extract_params args
    body = nil

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def exists_template(ts, %{name: name} = args) do
    method = HTTP_HEAD
    path   = Utils.pathify '_template', Utils.escape(name)
    params = Utils.extract_params args
    body = nil

    status200? ts, method, path, params, body
  end

  defdelegate exists_template?(ts, args \\ %{}), to: __MODULE__, as: :exists_template

end
