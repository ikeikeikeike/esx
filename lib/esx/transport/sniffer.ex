defmodule ESx.Transport.Sniffer do
  import ESx.R

  alias ESx.{Transport, Funcs}
  # alias ESx.Transport.Config

  @protocol "http"
  @timeout 1

  def urls(%{} = ts) do
    Transport.perform_request(ts, "GET", "_nodes/http", %{}, nil)
    |> response
    |> parse
  end

  defp parse({:ok, nodes}) do
    hosts =
      Map.get(nodes, "nodes", [])
      |> Enum.map(fn {_id, info} ->
        if info[@protocol] do
          [host, port] =
            get_in(info, [@protocol, "publish_address"])
            |> String.split(":")

          {port, _} = Integer.parse port

          config =
            [
              # id:          id,
              # name:        info["name"],
              # version:     info["version"],
              host:        String.replace(host, "inet[/", ""),
              port:        port,
              protocol:    @protocol,
              # roles:       info["roles"],
              # attributes:  info["attributes"]
            ]

          Funcs.build_url! config
        end
      end)

    hosts = hosts |> Enum.filter(& !!&1)

    if Transport.State.state.randomize_hosts do
      Enum.shuffle hosts
    else
      hosts
    end
  end
  defp parse(any), do: {:error, any}

end
