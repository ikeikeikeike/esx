defmodule ESx.Transport.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    children = [
      worker(ESx.Transport.Connection, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  def start_child(args) do
    Supervisor.start_child(__MODULE__, [args])
  end

  def count_children do
    Supervisor.count_children(__MODULE__)
  end
end
