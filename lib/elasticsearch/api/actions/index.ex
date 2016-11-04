defmodule Elasticsearch.API.Actions.Index do
  import Elasticsearch.API.R

  alias Elasticsearch.API.Utils
  alias Elasticsearch.Transport.Client

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

end
