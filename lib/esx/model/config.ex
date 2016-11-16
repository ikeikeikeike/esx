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

    [app: app, mod: mod] ++ extract_repo(app, cfg[:repo]) ++ build_url(cfg)
  end

  def extract_repo(app, nil), do: possibly_load app
  def extract_repo(app, repo) do
    case Code.ensure_loaded(repo) do
      {:module, repo} -> [repo: repo]
      _               -> possibly_load app
    end
  end

  # XXX: Gotta remove this.
  def possibly_load(app) do
    case Code.ensure_loaded(:"Elixir.#{Macro.camelize "#{app}"}.Repo") do
      {:module, repo} -> [repo: repo]
      _               -> []
    end
  end

  def build_url([url: url]) do
    case URI.parse(url) do
      %URI{scheme: nil} -> raise ArgumentError, "Missing scheme in Mix.Config"
      %URI{host: nil}   -> raise ArgumentError, "Missing host in Mix.Config"
      _                 -> [url: url]
    end
  end

  def build_url({:system, env}) when is_binary(env) do
    build_url [url: System.get_env(env)]
  end

  def build_url(cfg) when is_list(cfg) do
    u = struct URI, cfg
    u = if cfg[:protocol], do: Map.put(u, :scheme, cfg[:protocol]), else: u
    u = if cfg[:user], do: Map.put(u, :userinfo, "#{cfg[:user]}:#{cfg[:password]}"), else: u

    build_url [url: URI.to_string u]
  end
end
