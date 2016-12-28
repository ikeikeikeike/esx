Code.require_file "../../../test_helper.exs", __ENV__.file

defmodule ESx.Model.BaseTest do
  use ExUnit.Case
  doctest ESx

  import ESX.Test.Support.Checks

  alias ESX.Test.Support.Definition.{Model, Schema, NonameSchema}

  test "ok model.base no names" do
    rsp =  Model.search NonameSchema, %{}
    assert rsp == %ESx.Model.Search{
      __model__: ESX.Test.Support.Definition.Model,
      __schema__: ESX.Test.Support.Definition.NonameSchema,
      args: %{body: %{}, index: "definition-nonameschema", type: "definition-nonameschema"},
    }
  end

  test "ok model.base model and schema" do
    rsp = Model.search Schema, %{}

    assert rsp == %ESx.Model.Search{
      __model__: ESX.Test.Support.Definition.Model,
      __schema__: ESX.Test.Support.Definition.Schema,
      args: %{body: %{}, index: "test_schema_index", type: "test_schema_type"}
    }
  end

end
