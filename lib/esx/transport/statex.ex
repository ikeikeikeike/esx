defmodule ESx.Transport.Statex do
  @doc false
  defmacro __using__(opts) do
    quote do
      defstruct unquote(opts)
      @__struct_resource__ unquote(opts)

      def start_link(name \\ "", args \\ []) do
        args =
          if function_exported?(__MODULE__, :initialize_state, 1) do
            initialize_state args
          else
            args
          end

        Agent.start_link(fn -> struct(__MODULE__, args) end, name: namepid(name))
      end

      def state(name \\ "") do
        Agent.get(namepid(name), fn config -> config end)
      end

      def incr_state!(name \\ "", key, number) do
        Agent.get_and_update(namepid(name), fn s ->
          s = Map.update!(s, key, & &1 + number)
          {Map.get(s, key), s}
        end)
      end

      def set_state!(overwrite),        do: set_state!("", overwrite)
      def set_state!(name, overwrite)   do
        Agent.get_and_update(namepid(name), fn s ->
          s =
            Enum.reduce overwrite, s, fn {key, value}, acc ->
              Map.update!(acc, key, fn _ -> value end)
            end
          {s, s}
        end)
      end
      def set_state!(key, value),       do: set_state!("", key, value)
      def set_state!(name, key, value)  do
        set_state! name, Map.new([{key, value}])
      end

      def namepid(pid) when is_pid(pid) do
        pid
      end
      def namepid(name) do
        Enum.join([__MODULE__, name])
        |> :erlang.md5
        |> Base.encode16(case: :lower)
        |> String.to_atom
      end
    end
  end
end
