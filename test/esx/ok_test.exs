Code.require_file "../../test_helper.exs", __ENV__.file

defmodule ESx.ChecksTest do
  use ExUnit.Case
  doctest ESx

  import ESX.Test.Support.Checks

  test "ok.test" do
    m = %{ok: true}

    assert ok({:ok, m}, & &1[:ok]) == true
    assert ok({:ok, m}) == true

    assert ok({:error, m}, & &1[:ok]) == {:ng, %{ok: true}}
    assert ok({:error, m}) == {:ng, %{ok: true}}
  end

end
