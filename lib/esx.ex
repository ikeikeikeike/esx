defmodule ESx do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    children = [
      %{
        id: ESx.Transport.Connection.Supervisor,
        start: {ESx.Transport.Connection.Supervisor, :start_link, []}
      },
      %{id: ESx.Transport.State, start: {ESx.Transport.State, :start_link, []}},
      %{
        id: ESx.Transport.Selector.RoundRobin,
        start: {ESx.Transport.Selector.RoundRobin, :start_link, []}
      }
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ESx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
