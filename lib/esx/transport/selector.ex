defmodule ESx.Transport.Selector do

  defmodule Base do
    use Behaviour

    @callback select(conns::List.t) :: ESx.Transport.Connection.t | {:error, term}
  end

  defmodule Random do
    @moduledoc "Random Selector"
    @behaviour Base

    def select(conns) do
      Enum.random conns
    end
  end

  defmodule RoundRobin do
    @moduledoc "RoundRobin Selector"
    @behaviour Base

    use ESx.Transport.Statex, [current: 0]

    def select(conns) do
      s    = state()
      next =
        if s.current >= (length(conns) - 1) do
          0
        else
          1 + s.current
        end

      conn = Enum.at conns, next
      set_state! :current, next

      conn
    end

  end

end
