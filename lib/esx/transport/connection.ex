defmodule ESx.Transport.Connection do
  alias ESx.Transport.Connection.Supervisor

  use ESx.Transport.Statex, [
    :pidname, :url, :client,
    :dead_since, dead: false,
    failures: 0, resurrect_timeout: 60,
  ]

  def initialize_state(args) do
    Keyword.merge args, [
      pidname: namepid(args[:url]),
      dead_since: :os.system_time(:seconds),
    ]
  end

  @client HTTPoison  # XXX: to be abstraction

  # TODO: Allow setting optional in arguments which is struct's value
  def pool([{:url, url} | _]), do: pool url
  def pool(url) do
    Supervisor.start_child url, [url: url, client: @client]
  end

  def pools do
    Supervisor.which_children
    |> Enum.map(fn {_, pid, _, _conn} ->
      state pid
    end)
  end

  def dead?(name) do
    s = state name
    s.dead
  end

  # TODO: poolboy, transaction
  def dead!(name) do
    Agent.get_and_update namepid(name), fn conn ->
       conn = %{conn | dead: true, dead_since: :os.system_time(:seconds)}
       conn = Map.update!(conn, :failures, & &1 + 1)
      {conn, conn}
    end
  end

  def alive?(name) do
    s = state name
    not s.dead
  end

  # TODO: poolboy, transaction
  def alive!(name) do
    set_state! name, :dead, false
  end

  def healthy!(name) do
    set_state! name, %{dead: false, failures: 0}
  end

  def resurrect!(name) do
    if resurrectable?(name), do: alive! name
  end

  # TODO: poolboy, transaction
  def resurrectable?(name) do
    s = state name

    left  = :os.system_time(:seconds)
    right = s.dead_since + (s.resurrect_timeout * :math.pow(2, s.failures - 1))
    left > right
  end

end
