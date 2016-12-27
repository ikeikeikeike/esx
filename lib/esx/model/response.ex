defmodule ESx.Model.Response do
  defstruct [
    :took, :timed_out, :shards, :total, :max_score,
    :aggregations, :suggestions, :__schema__, :__model__,
    hits: [], records: [],
  ]

  @type t :: %__MODULE__{}

  use ESx.Model.Response.Ecto  # TODO: tobe abstraction

  def parse(_model, _schema, {:ok, %{"error" => _} = rsp}), do: rsp
  def parse(model, schema, {:ok, %{} = rsp}) do
    %__MODULE__{
      __model__: model,
      __schema__: schema,
      hits: rsp["hits"]["hits"],
      total: rsp["hits"]["total"],
      max_score: rsp["hits"]["max_score"],
      took: rsp["took"],
      timed_out: rsp["timed_out"],
      shards: rsp["_shards"],
      aggregations: rsp["aggregations"] || rsp["facets"],
    }
  end

  def results(%{__model__: model, __schema__: schema} = search) do
    rsp = ESx.Model.Search.execute search
    parse model, schema, rsp
  end

  def aggregations(_st) do
    # Aggregations.new(response['aggregations'])
  end

  def suggestions(_st) do
    # Suggestions.new(response['suggest'])
  end

  defimpl Enumerable, for: ESx.Model.Response do

    def count(%ESx.Model.Response{total: total}), do: total

    def member?(%ESx.Model.Response{records: records}, value)
    when length(records) > 0 do
      value in records
    end
    def member?(%ESx.Model.Response{hits: hits}, value) do
      value in hits
    end

    def reduce(%ESx.Model.Response{records: records}, acc, fun)
    when length(records) > 0 do
      Enumerable.reduce(records, acc, fun)
    end
    def reduce(%ESx.Model.Response{hits: hits}, acc, fun) do
      Enumerable.reduce(hits, acc, fun)
    end
  end

end
