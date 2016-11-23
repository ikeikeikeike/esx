defmodule ESx.Transport.Connection do
  alias ESx.Transport.Connection.Supervisor

  defstruct [
    :pidname, :url, :client,
    :dead_since, dead: false,
    failures: 0, resurrect_timeout: 60,
  ]

  @client HTTPoison  # XXX: to be abstraction

  # TODO: Allow setting optional in arguments which is struct's value
  def pool([{:url, url} | _]), do: pool url
  def pool(url) do
    Supervisor.start_child [url: url, client: @client]
  end

  def connections do
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
       conn = Map.update!(conn, :failures, fn n -> n + 1 end)
      {conn, conn}
    end
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

  def state(name) do
    Agent.get(namepid(name), fn conn -> conn end)
  end

  def set_state!(name, overwrite) do
    Agent.get_and_update(namepid(name), fn conn ->
      conn =
        Enum.reduce overwrite, conn, fn {key, value}, acc ->
          Map.update!(acc, key, fn _ -> value end)
        end
      {conn, conn}
    end)
  end
  def set_state!(name, key, value) do
    set_state! name, Map.new([{key, value}])
  end

  defp namepid(pid) when is_pid(pid) do
    pid
  end
  defp namepid(name) do
    Enum.join([__MODULE__, name])
    |> :erlang.md5
    |> Base.encode16(case: :lower)
    |> String.to_atom
  end

  def start_link(args \\ []) do
    name = namepid(args[:url])
    conn = %__MODULE__ {
      pidname: name,
      dead_since: :os.system_time(:seconds),
    }

    Agent.start_link(fn -> struct conn, args end, name: name)
  end

end
