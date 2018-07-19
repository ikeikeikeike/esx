Code.require_file("../../../test_helper.exs", __ENV__.file)

defmodule ESx.APIs.IndicesTest do
  use ExUnit.Case
  doctest ESx

  # import ESx.Test.Support.Checks

  alias ESx.{Transport, API.Indices}

  @ts %Transport{trace: false}

  test "ok apis.indices.alias" do
    [index, name] = ["test_es_index", "test_es_alias"]
    Indices.delete(@ts, index: index)

    rsp = Indices.create(@ts, %{index: index, body: %{}})
    assert rsp == {:ok, %{"acknowledged" => true, "shards_acknowledged" => true}}

    rsp = Indices.put_alias(@ts, %{index: index, name: name})
    assert rsp == {:ok, %{"acknowledged" => true}}

    rsp = Indices.exists_alias?(@ts, %{index: index, name: name})
    assert rsp == true

    rsp = Indices.get_alias(@ts, %{index: index, name: name})
    assert rsp == {:ok, %{index => %{"aliases" => %{name => %{}}}}}

    rsp = Indices.delete_alias(@ts, %{index: index, name: name})
    assert rsp == {:ok, %{"acknowledged" => true}}

    rsp = Indices.delete(@ts, index: index)
    assert rsp == {:ok, %{"acknowledged" => true}}
  end
end
