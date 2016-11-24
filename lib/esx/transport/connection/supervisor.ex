defmodule ESx.Transport.Connection.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    children = [
      worker(ESx.Transport.Connection, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one, name: __MODULE__)
  end

  def start_child(name, args) do
    Supervisor.start_child(__MODULE__, [name, args])
  end

  def count_children do
    Supervisor.count_children(__MODULE__)
  end

  def which_children do
    Supervisor.which_children(__MODULE__)
  end

end
