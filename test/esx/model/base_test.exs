Code.require_file "../../../test_helper.exs", __ENV__.file

defmodule ESx.Model.BaseTest do
  use ExUnit.Case
  doctest ESx

  import ESX.Test.Support.Checks

  alias ESX.Test.Support.Definition.{Model, Schema, NonameSchema}

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
      app: :esx, mod: Model, trace: true
    ]
  end

  test "ok model.base.transport" do
    assert 0 == length(ESx.Transport.Connection.conns)

    Model.transport

    conn =
      ESx.Transport.Connection.conns
      |> List.first

    assert "http://localhost:9200" == conn.url
    assert "http://localhost:9200" == ESx.Funcs.decid(conn.pidname)
  end

  test "ok model.base.repo" do
    assert nil == Model.repo
  end

  test "ok model.base.search with repo" do
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

  test "ok model.base.create_index" do
    Model.delete_index(Schema, %{})

    rsp = Model.create_index(Schema, %{})
    assert ok(rsp, & &1["acknowledged"]) == true

    rsp = Model.delete_index(Schema, %{})
    assert ok(rsp, & &1["acknowledged"]) == true
  end

end
