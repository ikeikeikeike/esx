Code.require_file "../../../test_helper.exs", __ENV__.file

defmodule ESx.Model.BaseTest do
  use ESx.Test.TestCase
  # use ExUnit.Case

  doctest ESx

  import ESx.Test.Support.Checks

  alias ESx.{API, API.Indices}
  alias ESx.Test.Support.Repo
  alias ESx.Test.Support.Definition.{Model, Schema, NonameSchema, RepoSchema, BulkSchema}

  test "ok model.base no names" do
    rsp =  Model.search NonameSchema, %{}
    assert rsp == %ESx.Model.Search{
      __model__: Model,
      __schema__: NonameSchema,
      args: %{body: %{},
        index: "definition-nonameschema",
        type: "definition-nonameschema",
      },
    }
  end

  test "ok model.base model and schema" do
    rsp = Model.search Schema, %{}

    assert rsp == %ESx.Model.Search{
      __model__: Model,
      __schema__: Schema,
      args: %{body: %{},
        index: "test_schema_index",
        type: "test_schema_type",
      },
    }
  end

  test "ok model.base.config" do
    assert Model.config == [
      url: "http://localhost:9200",
      repo: ESx.Test.Support.Repo,
      app: :esx, mod: Model, trace: false
    ]
  end

  test "ok model.base.transport" do
    Model.transport

    conn =
      ESx.Transport.Connection.conns
      |> List.first

    assert "http://localhost:9200" == conn.url
    assert "http://localhost:9200" == ESx.Funcs.decid(conn.pidname)
  end

  test "ok model.base.search" do
    rsp = Model.search(Schema, ~s({"some": "of", "queries": "s*"})).args.body
    assert "{\"some\": \"of\", \"queries\": \"s*\"}" ==  rsp

    rsp = Model.search(Schema, %{some: "of", queries: true}).args.body
    assert %{some: "of", queries: true} == rsp

    rsp = Model.search(Schema, "+some:of +queries:s*").args.q
    assert "+some:of +queries:s*" == rsp

    rsp = Model.search(Schema, %{}, index: "my-index").args
    assert %{body: %{}, index: "my-index", type: "test_schema_type"} == rsp

    rsp = Model.search(Schema, %{}, type: "my-type", index: "my-index").args
    assert %{body: %{}, index: "my-index", type: "my-type"} == rsp
  end

  test "ok model.base.create_index with some of operation" do
    Model.delete_index(Schema)
    Model.delete_index(Schema, index: "abc-index")

    assert ok(Model.create_index(Schema), & &1["acknowledged"]) == true
    assert ok(Model.refresh_index(Schema), & get_in(&1, ["_shards", "failed"])) == 0
    assert Model.index_exists?(Schema) == true
    assert ok(Model.delete_index(Schema), & &1["acknowledged"]) == true

    assert ok(Model.create_index(Schema, index: "abc-index"), & &1["acknowledged"]) == true
    assert ok(Model.refresh_index(Schema, index: "abc-index"), & get_in(&1, ["_shards", "failed"])) == 0
    assert Model.index_exists?(Schema, index: "abc-index") == true
    assert ok(Model.delete_index(Schema, index: "abc-index"), & &1["acknowledged"]) == true
  end

  test "ok model.base.repo" do
    assert ESx.Test.Support.Repo == Model.repo
  end

  test "ok model.base.search with repo" do
    Repo.delete_all RepoSchema
    Indices.delete Model.transport, %{index: "*"}

    assert [] == Repo.all(RepoSchema)

    Repo.insert %RepoSchema{title: "a"}
    Repo.insert %RepoSchema{title: "b"}
    Repo.insert %RepoSchema{title: "c"}
    Repo.insert %RepoSchema{title: "d"}
    assert 4 == length(Repo.all(RepoSchema))
  end

  test "ok apis.api.reindex with large data" do
    Repo.delete_all BulkSchema
    Indices.delete Model.transport, %{index: "*"}

    assert 0 == API.count!(Model.transport)["count"]

    Repo.insert_all BulkSchema, Enum.map(1..50000, & [title: to_string(&1) <> Ecto.UUID.generate])
    Repo.insert_all BulkSchema, Enum.map(1..10, & [title: to_string(&1) <> Ecto.UUID.generate])

    Model.reindex BulkSchema

    assert 0 < API.count!(Model.transport)["count"]  # TODO: flash
  end

end
