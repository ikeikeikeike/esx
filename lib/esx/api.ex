defmodule ESx.API do
  import ESx.API.R

  alias ESx.API.Utils
  alias ESx.Transport

  def info(ts, _args \\ %{}) do
    {method, path, params, body} = blank_args

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end
  def info!(ts, _args \\ %{}) do
    info(ts)
    |> response!
  end

  def ping(ts, _args \\ %{}) do
    {method, path, params, body} = blank_args

    status200? ts, method, path, params, body
  end

  def ping!(ts, _args \\ %{}) do
    case ping(ts) do
      rs when is_boolean(rs) ->
        rs
      {:error, err} ->
        raise err
    end
  end

  def index(ts, %{index: index, type: type} = args) do
    method = if args[:id], do: "PUT", else: "POST"
    path   = Utils.pathify [Utils.escape(index), Utils.escape(type), Utils.escape(args[:id])]
    params = Utils.extract_params args, [:id]
    body   = args[:body]

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def reindex(ts, %{body: body} = args) do
    method = 'POST'
    path   = "_reindex"
    params = Utils.extract_params args
    body   = body

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  @doc """
  # http://elasticsearch.org/guide/reference/api/index_/
  """
  def create(ts, args \\ %{}) do
    index ts, Map.put(args, :op_type, "create")
  end

  def update(ts, %{index: index, type: type, id: id} = args) do
    method = "POST"
    path   = Utils.pathify [Utils.escape(index), Utils.escape(type), Utils.escape(id), "_update"]
    params = Utils.extract_params args
    body   = args[:body]

    # TODO: The arguments will become querystring in Transport.perform_request
    params =
      Map.merge params, (if fields = params[:fields] do
        %{fields: Utils.listify(fields)}
      else
        %{}
      end)

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def bulk(ts, args \\ %{}) do
    {type, args} = Map.pop(args, :type)

    method = "POST"
    path   = Utils.pathify [Utils.escape(args[:index]), Utils.escape(type), '_bulk']
    params = Utils.extract_params args
    body   = args[:body]

    payload =
      case body do
        body when is_list(body) ->
          Utils.bulkify(body)
        body ->
          body
      end

    Transport.perform_request(ts, method, path, params, payload)
    |> response
  end

  def search(ts, args \\ %{}) do
    args =
      if !args[:index] && args[:type] do
        Map.put args, :index, "_all"
      else
        args
      end

    method = "GET"
    path   = Utils.pathify [Utils.listify(args[:index]), Utils.listify(args[:type]), "_search"]
    params = Utils.extract_params args
    body   = args[:body]

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def search!(ts, args \\ %{}) do
    search(ts, args)
    |> response!
  end
end
