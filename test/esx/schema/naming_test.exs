Code.require_file "../../../test_helper.exs", __ENV__.file

defmodule ESx.Model.NamingTest do
  use ExUnit.Case
  doctest ESx

  import ESX.Test.Support.Checks

  alias ESX.Test.Support.Definition.{Model, Schema, NonameSchema, NoDSLSchema}

  test "ok schema.naming" do
    IO.puts "\nnot implementation here #{inspect __DIR__}.#{inspect __MODULE__}"
  end

end
