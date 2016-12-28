Code.require_file "../../test_helper.exs", __ENV__.file

defmodule ESx.ChecksTest do
  use ExUnit.Case
  doctest ESx

  import ESX.Test.Support.Checks

  test "ok.test" do
    m = %{ok: true}

    assert ok({:ok, m}, & &1[:ok]) == true
    assert ok({:ok, m}) == true

    assert ok({:error, m}, & &1[:ok]) == false
    assert ok({:error, m}, & &1[:ok]) == false
  end

end
