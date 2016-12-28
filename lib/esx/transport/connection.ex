defmodule ESx.Transport.Connection do
  use ESx.Transport.Statex, [
    :pidname, :url, :client,
    :dead_since, dead: false,
    failures: 0, resurrect_timeout: 60,
  ]
  def initialize_state(args) do
    Keyword.merge args, [
      pidname: pidname(args[:url]),
      dead_since: :os.system_time(:seconds),
    ]
  end

  import ESx.Checks, only: [blank?: 1, present?: 1]

  alias ESx.Transport.Selector
  alias ESx.Transport.Connection.Supervisor

  @type t :: %__MODULE__{}
  @client HTTPoison  # XXX: to be abstraction

  # TODO: Allow setting optional in arguments which is struct's value
  #
  #
  def start_conn([{:url, url} | opts]) do
    start_conn url, opts
  end
  def start_conn(url, opts) do
    Supervisor.start_child url, [url: url, client: @client] ++ opts
  end

  def delete(name) do
    Supervisor.remove_child id(name)
  end

  def conn(opts \\ []) do
    if blank?(alives()) do
      deadconn = List.first(Enum.sort(dead_conns, & &1.failures > &2.failures))
      if deadconn, do: alive!(deadconn)
    end

    cc = alives()
    if present?(cc), do: Selector.RoundRobin.select(cc)
  end

  def conns do
    Supervisor.which_children
    |> Enum.map(fn {name, pid, _, _conn} ->
      state Funcs.decid(name)
    end)
  end

  def alives do
    conns()
    |> Enum.filter(& alive? id(&1))
  end

  def dead_conns do
    conns()
    |> Enum.filter(& dead? id(&1))
  end

  def dead?(name) do
    s = state id(name)
    s.dead
  end

  def dead!(name) do
    Agent.get_and_update pidname(id(name)), fn conn ->
       conn = %{conn | dead: true, dead_since: :os.system_time(:seconds)}
       conn = Map.update!(conn, :failures, & &1 + 1)
      {conn, conn}
    end
  end

  def alive?(name) do
    s = state id(name)
    not s.dead
  end

  def alive!(name) do
    set_state! id(name), :dead, false
  end

  def healthy!(name) do
    set_state! id(name), %{dead: false, failures: 0}
  end

  def dead?(name) do
    s = state id(name)
    s.dead
  end

  def resurrect!(name) do
    if resurrectable?(name), do: alive! name
  end

  def resurrectable?(name) do
    s = state id(name)
    failures = if s.failures > 1000, do: 1000, else: s.failures

    left  = :os.system_time(:seconds)
    right = s.dead_since + (s.resurrect_timeout * :math.pow(2, failures - 1))
    left > right
  end

  def checkout do
    Supervisor.which_children
    |> Enum.map(fn {_name, pid, _, _conn} ->
      checkout(pid)
    end)
  end
  def checkout(name) do
    id(name)
    |> Supervisor.checkout
    |> state
  end

  def checkin([%__MODULE__{pidname: pid, url: url} | _] = structs) do
    Enum.each structs, &checkin/1
  end
  def checkin(%__MODULE__{pidname: pid, url: url}) do
    pid = Process.whereis pid
    Supervisor.checkin url, pid
  end

  defp id(%__MODULE__{url: url}), do: url
  defp id(name), do: name

end
