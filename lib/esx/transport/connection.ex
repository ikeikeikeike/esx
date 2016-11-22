defmodule ESx.Transport.Connection do
  alias ESx.Transport.Connection.Supervisor

  defstruct [:poolname, :url, :client, dead: false, failures: 0]

  @client HTTPoison  # XXX: to be abstraction

  def pool([{:url, url} | _]), do: pool url
  def pool(url) do
    Supervisor.start_child [url: url, client: @client]
  end

  def connections do
    Supervisor.which_children
    |> Enum.map(fn {_, pid, _, _conn} ->
      pid
    end)
  end

  def get(url) do
    Agent.get(namepid(url), fn conn -> conn end)
  end

  def set(url, key, value) do
    Agent.update(namepid(url), fn conn ->
      Map.update!(conn, key, fn _ -> value end)
    end)
  end

  def update(url, overwrite) do
    Enum.each overwrite, fn {key, value} ->
      set(url, key, value)
    end
  end

  def namepid(pid) when is_pid(pid) do
    pid
  end
  def namepid(url) do
    Enum.join([__MODULE__, url])
    |> :erlang.md5
    |> Base.encode16(case: :lower)
    |> String.to_atom
  end

  def start_link(args \\ []) do
    name = namepid(args[:url])
    fields = Keyword.merge args, [poolname: name]

    Agent.start_link(fn -> struct __MODULE__, fields end, name: name)
  end

end
