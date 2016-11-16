defmodule ESx.Model.Response do
  @before_compile ESx.Model.Ecto

  defstruct [
    :took, :timed_out, :shards, :hits, :total, :max_score,
    :records, :aggregations, :suggestions, :__model__
  ]

  def parse(model, {:ok, %{"error" => _} = rsp}), do: rsp
  def parse(model, {:ok, %{} = rsp}) do
    %__MODULE__{
      hits: rsp["hits"]["hits"],
      total: rsp["hits"]["total"],
      max_score: rsp["hits"]["max_score"],
      took: rsp["took"],
      timed_out: rsp["timed_out"],
      shards: rsp["_shards"],
      __model__: model,
    }
  end

  def aggregations(st) do
    # Aggregations.new(response['aggregations'])
  end

  def suggestions(st) do
    # Suggestions.new(response['suggest'])
  end

end
