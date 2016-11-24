defmodule ESx.Transport.Collection do
  import ESx.Checks, only: [blank?: 1]

  alias ESx.Transport.Selector
  alias ESx.Transport.Connection

  def alives do
    Connection.pools
    |> Enum.filter(&Connection.alive?/1)
  end

  def pool(opts \\ []) do
    if blank?(alives) do
      deadpool = List.first(Enum.sort(deadpools, & &1.failures > &2.failures))
      if deadpool, do: deadpool.alive!
    end

    Selector.select(opts)
  end

  def deadpools do
    Connection.pools
    |> Enum.filter(&Connection.dead?/1)
  end

end
