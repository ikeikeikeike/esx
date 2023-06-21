defmodule ESx.Model.Config do
  @doc """
  """
  def resource(mod, opts) do
    app = Keyword.fetch!(opts, :app)
    cfg = parse_config(mod, app)

    {app, cfg}
  end

  def parse_config(mod, app) do
    cfg =
      case Application.get_env(app, mod) do
        nil ->
          Application.get_env(app, ESx.Model, url: "http://127.0.0.1:9200")

        cfg ->
          cfg
      end

    unless cfg do
      raise ArgumentError,
            "In #{mod} Module's app: #{inspect(app)} was missing " <>
              "configuration. There's not it in Mix.Config. " <>
              "Please see here https://github.com/ikeikeikeike/esx#configuration"
    end

    {repo, cfg} = Keyword.pop(cfg, :repo)
    {trace, cfg} = Keyword.pop(cfg, :trace)

    extract_repo(app, repo) ++
      [app: app, mod: mod, trace: trace || false] ++
      cfg
  end

  def extract_repo(app, nil), do: possibly_load(app)

  def extract_repo(app, repo) do
    case repo do
      nil -> possibly_load(app)
      repo -> [repo: repo]
    end
  end

  # XXX: Gotta remove this.
  def possibly_load(app) do
    case Code.ensure_loaded(:"Elixir.#{Macro.camelize("#{app}")}.Repo") do
      {:module, repo} -> [repo: repo]
      _ -> []
    end
  end
end
