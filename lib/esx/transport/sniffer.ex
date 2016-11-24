defmodule ESx.Transport.Sniffer do
  import ESx.R
  alias ESx.Transport

  @protocol "http"
  @timeout 1

  def urls(%{} = ts) do
    nodes =
      Transport.perform_request(ts, "GET", "_nodes/http", %{}, nil)
      |> response

    hosts =
      Map.get(nodes, "nodes", [])
      |> Enum.map(fn {id, info} ->
        if info[@protocol] do
          [host, port] =
            get_in(info, [@protocol, "publish_address"])
            |> String.splite(":")

          %{
            id:          id,
            name:        info["name"],
            version:     info["version"],
            host:        host,
            port:        port,
            roles:       info["roles"],
            attributes:  info["attributes"]
          }
        end
      end)
      |> Enum.filter(& !!&1)

    if Transport.State.state.randomize_hosts do
      Enum.shuffle hosts
    else
      hosts
    end
  end

end
