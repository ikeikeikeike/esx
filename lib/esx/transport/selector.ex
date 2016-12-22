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

    use ESx.Transport.Statex, [next: 0]

    def select(conns) do
      s    = state()
      conn = Enum.at conns, s.next
      next =
        if s.next >= (length(conns) - 1) do
          0
        else
          1 + s.next
        end

      set_state! :next, next

      conn
    end

  end

end
