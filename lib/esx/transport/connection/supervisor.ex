defmodule ESx.Transport.Connection.Supervisor do
  @moduledoc false
  use Supervisor

  alias ESx.Funcs

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Supervisor.start_link(__MODULE__, [], strategy: :one_for_one, name: __MODULE__)
  end

  def poolname(pid) when is_pid(pid) do
    pid
  end

  def poolname(name) do
    Funcs.encid([:poolboy, ESx.Transport.Connection], name)
  end

  def start_child(name, args) do
    id = poolname(name)

    conn_opts = Keyword.put(args, :name, name)

    poolboy_opts = [
      {:name, {:local, id}},
      {:worker_module, ESx.Transport.Connection},
      {:size, 1},
      {:max_overflow, 0}
    ]

    worker = :poolboy.child_spec(id, poolboy_opts, conn_opts)
    Supervisor.start_child(__MODULE__, worker)
  end

  def count_children do
    Supervisor.count_children(__MODULE__)
  end

  def which_children do
    Supervisor.which_children(__MODULE__)
  end

  def remove_child(name) do
    id = poolname(name)
    Supervisor.terminate_child(__MODULE__, id)
    Supervisor.delete_child(__MODULE__, id)
  end

  def transaction(name, fun) do
    :poolboy.transaction(poolname(name), &fun.(&1))
  end

  def checkout(name) do
    :poolboy.checkout(poolname(name))
  end

  def checkin(name, pid) do
    :poolboy.checkin(poolname(name), pid)
  end
end
