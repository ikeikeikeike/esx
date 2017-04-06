Code.require_file "../../../test_helper.exs", __ENV__.file

defmodule ESx.Model.BaseTest do
  use ESx.Test.TestCase
  # use ExUnit.Case

  doctest ESx

  import ESx.Test.Support.Checks

  alias ESx.Test.Support.Definition.{Model, Schema, NonameSchema, RepoSchema}

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
    assert nil == Model.repo
  end

  test "ok model.base.search with repo" do
    ESx.Test.Support.Repo.all RepoSchema
  end

  test "ok apis.api.reindex with repo" do
    # IO.inspect Model.reindex Schema
  end

end
