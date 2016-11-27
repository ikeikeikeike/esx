defmodule ESx.Transport.Connection.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    supervise([], strategy: :one_for_one, name: __MODULE__)
  end

  def start_child(name, args) do
    id = ESx.Funcs.nameid(__MODULE__, name)

    worker = worker(ESx.Transport.Connection, [name, args], id: id, restart: :transient)
    Supervisor.start_child(__MODULE__, worker)
  end

  def remove_child(name) do
    id = ESx.Funcs.nameid(__MODULE__, name)

    Supervisor.terminate_child(__MODULE__, id)
    Supervisor.delete_child(__MODULE__, id)
  end

  def count_children do
    Supervisor.count_children(__MODULE__)
  end

  def which_children do
    Supervisor.which_children(__MODULE__)
  end

end
