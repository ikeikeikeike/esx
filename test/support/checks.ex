defmodule ESX.Test.Support.Checks do

  def ok({:ok, _value}), do: true
  def ok({_ng, _value}), do: false
  def ok({:ok, value}, fun), do: fun.(value)
  def ok({_ng, _value}, _fun), do: false

end
