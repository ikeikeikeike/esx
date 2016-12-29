defmodule ESX.Test.Support.Checks do
  @moduledoc false

  def ok({:ok, _value}), do: true
  def ok({_ng, value}), do: {:ng, value}
  def ok({:ok, value}, fun) when is_function(fun), do: fun.(value)
  def ok({:ok, value}, key), do: value[key]
  def ok({_ng, value}, _fun), do: {:ng, value}

end
