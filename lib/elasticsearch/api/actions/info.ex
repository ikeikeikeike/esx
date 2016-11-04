defmodule Elasticsearch.API.Actions.Info do
  import Elasticsearch.API.R

  alias Elasticsearch.API.Utils
  alias Elasticsearch.Transport.Client

  def info(%Client{} = ts, _args \\ %{}) do
    {method, path, params, body} = blank_args

    Client.perform_request(ts, method, path, params, body)
    |> response
  end
  def info!(%Client{} = ts, _args \\ %{}) do
    info(ts)
    |> response!
  end

end
