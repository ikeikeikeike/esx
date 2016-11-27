defmodule ESx.Transport.Selector do

  defmodule Base do
    use Behaviour

    @callback select(conns::List.t) :: ESx.Transport.Connection.t | {:error, term}
  end

  defmodule Random do
    @behaviour ESx.Transport.Selector.Base

    def select(conns) do
      Enum.random conns
    end
  end

  defmodule RoundRobin do
    use ESx.Transport.Statex, [next: 0]
    @behaviour ESx.Transport.Selector.Base

    def select(conns) do
      s = state
      conn = Enum.at conns, s.next

      next =
        if s.next >= length(conns) do
          0
        else
          1 + s.next
        end

      set_state! :next, next
      conn
    end

  end

end
