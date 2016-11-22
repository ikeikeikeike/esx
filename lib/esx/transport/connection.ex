defmodule ESx.Transport.Connection do
  defstruct [:pidname, :host, :client, dead: false, failures: 0]

  def start_link(args \\ []) do
    name = namepid(args[:host])
    fields = Keyword.merge args, [name: name]

    Agent.start_link(fn -> struct __MODULE__, fields end, name: name)
  end

  def namepid(host) do
    Enum.join([__MODULE__, host])
    |> :erlang.md5
    |> Base.encode16(case: :lower)
    |> String.to_atom
  end

  def get(name) do
    Agent.get(name, fn conn -> conn end)
  end

  def set(name, key, value) do
    Agent.update(name, fn conn ->
      Map.update!(conn, key, fn _ -> value end)
    end)
  end

  def update(name, overwrite) do
    Enum.each overwrite, fn {key, value} ->
      set(name, key, value)
    end
  end

end
