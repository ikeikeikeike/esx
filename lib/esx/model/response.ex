defmodule ESx.Model.Response do

  defstruct [
    :took, :timed_out, :shards, :hits, :total, :max_score,
    :records, :aggregations, :suggestions, :__model__
  ]

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

  if Code.ensure_loaded?(Ecto) do
    def records(st, queryable) do
      repo = st.__model__.repo

      ids = Enum.map hits, & &1["_id"]
      records = repo.all(Ecto.Query.from q in queryable, where: q.id in ^ids)

      Enum.map hits, fn hit ->
        [record] = Enum.filter records, & "#{hit["_id"]}" == "#{&1.id}"
        List.delete records, record
        record
      end
    end
  else
    def records(_st, _queryable) do
      raise "could not load `Ecto` module. please install it."
    end
  end

end
