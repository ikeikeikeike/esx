defmodule ESx.Model.Response do
  @before_compile ESx.Model.Response.Ecto  # TODO: tobe abstraction

  defstruct [
    :took, :timed_out, :shards, :hits, :total, :max_score,
    :records, :aggregations, :suggestions, :__schema__, :__model__
  ]

  def parse(_model, _schema, {:ok, %{"error" => _} = rsp}), do: rsp
  def parse(model, schema, {:ok, %{} = rsp}) do
    %__MODULE__{
      hits: rsp["hits"]["hits"],
      total: rsp["hits"]["total"],
      max_score: rsp["hits"]["max_score"],
      took: rsp["took"],
      timed_out: rsp["timed_out"],
      shards: rsp["_shards"],
      __schema__: schema,
      __model__: model,
    }
  end

  def aggregations(_st) do
    # Aggregations.new(response['aggregations'])
  end

  def suggestions(_st) do
    # Suggestions.new(response['suggest'])
  end

end
