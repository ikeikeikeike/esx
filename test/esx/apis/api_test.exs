Code.require_file "../../../test_helper.exs", __ENV__.file

defmodule ESx.APIs.APITest do
  use ExUnit.Case
  doctest ESx

  import ESx.Test.Support.Checks

  alias ESx.{Transport, API, API.Indices}

  @ts %Transport{trace: false}

  test "ok apis.api.info" do
    rsp = API.info(@ts)

    assert ok(rsp, & &1["cluster_name"]) == "elasticsearch"
  end

  test "ok apis.api.ping" do
    assert API.ping(@ts) == true
  end

  test "ok apis.api.indexes" do
    rsp = API.index(@ts, %{index: "test_index", type: "test_type", body: %{}})

    assert ok(rsp, & &1["_index"]) == "test_index"
    assert ok(rsp, & &1["_type"]) == "test_type"

    rsp = Indices.delete(@ts, %{index: "test_index", type: "test_type"})
    assert ok(rsp, & &1["acknowledged"]) == true
  end

end
