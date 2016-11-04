defmodule Elasticsearch.API.Actions.Ping do
  import Elasticsearch.API.R

  alias Elasticsearch.Transport.Client

  def ping(%Client{} = ts, _args \\ %{}) do
    {method, path, params, body} = blank_args

    status200? ts, method, path, params, body
  end

  def ping!(%Client{} = ts, _args \\ %{}) do
    case ping(ts) do
      rs when is_boolean(rs) ->
        rs
      {:error, err} ->
        raise err
    end
  end

end
