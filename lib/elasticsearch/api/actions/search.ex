defmodule Elasticsearch.API.Actions.Search do
  import Elasticsearch.API.R

  alias Elasticsearch.API.Utils
  alias Elasticsearch.Transport.Client

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
