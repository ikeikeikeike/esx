defmodule Elasticsearch.API.Indices.Actions do
  import Elasticsearch.API.R

  alias Elasticsearch.API.Utils
  alias Elasticsearch.Transport.Client

  def delete(%Client{} = ts, args \\ %{}) do
    method = "DELETE"
    path   = Utils.pathify Utils.listify(args[:index])
    params = %{}
    body   = nil

    Client.perform_request(ts, method, path, params, body)
    |> response
  end

end
