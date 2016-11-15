defmodule ESx.Model.Config do
  @doc """
  """
  def resource(mod, opts) do
    app = Keyword.fetch!(opts, :app)
    cfg  = parse_config(mod, app)

    transport = ESx.Transport.transport Enum.into(cfg, %{})
    unless transport do
      raise ArgumentError, "missing configuration for transport in " <>
                           "config #{inspect app}, #{inspect mod}"
    end

    {app, transport, cfg}
  end

  def parse_config(mod, app) do
    cfg =
      case Application.get_env(app, mod) do
        nil ->
          Application.get_env(app, ESx.Model)
        cfg ->
          cfg
      end

    unless cfg do
      raise ArgumentError,
        "In #{mod} Module's app: #{inspect app} was missing " <>
        "configuration. There's not it in Mix.Config."
    end

    [app: app, mod: mod] ++ parse_config(cfg)
  end

  def parse_config(""), do: []

  def parse_config([url: url]) do
    case URI.parse(url) do
      %URI{scheme: nil} -> raise ArgumentError, "Missing scheme in Mix.Config"
      %URI{host: nil}   -> raise ArgumentError, "Missing host in Mix.Config"
      _                 -> [url: url]
    end
  end

  def parse_config({:system, env}) when is_binary(env) do
    parse_config [url: System.get_env(env)]
  end

  def parse_config(cfg) when is_list(cfg) do
    u = struct URI, cfg
    if cfg[:protocol], do: u = Map.put u, :scheme, cfg[:protocol]
    if cfg[:user], do: u = Map.put u, :userinfo, "#{cfg[:user]}:#{cfg[:password]}"

    parse_config [url: URI.to_string u]
  end
end
