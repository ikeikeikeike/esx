defmodule ESx.Model.Response do

  defstruct [:took, :timed_out, :shards, :hits, :total, :max_score, :response]

  def parse({:ok, %{} = rsp}) do
    %__MODULE__{
      took: rsp["took"],
      timed_out: rsp["timed_out"],
      shards: rsp["shards"],
      hits: rsp["hits"]["hits"],
      total: rsp["hits"]["total"],
      max_score: rsp["hits"]["max_score"],
      response: rsp,
    }
  end

  def records(st) do
  end

  def aggregations(st) do
    # Aggregations.new(response['aggregations'])
  end

  def suggestions(st) do
    # Suggestions.new(response['suggest'])
  end
end
