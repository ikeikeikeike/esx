defmodule Elasticsearch.Model.Supervisor do
  @moduledoc false
  use Supervisor

  @doc """
  """
  def start_link(mod, otp_app, opts) do
    opts = transport(mod, otp_app, opts)
    name = opts[:name] || Application.get_env(otp_app, mod)[:name] || mod
    Supervisor.start_link(__MODULE__, {mod, otp_app, opts}, [name: name])
  end

  @doc """
  """
  def transport(mod, otp_app, opts) do
    config =
      case Application.get_env(otp_app, mod) do
        nil ->
          Application.get_env(otp_app, Elasticsearch.Model)
        config ->
          config
      end

    config = Keyword.merge(config, opts)
    {url, config} = Keyword.pop(config, :url)
    [otp_app: otp_app, mod: mod] ++ Keyword.merge(config, parse_url(url || ""))
  end

  @doc """
  """
  def parse_config(mod, opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    config  = Application.get_env(otp_app, mod, [])

    {otp_app, config}
  end

  @doc """
  """
  def parse_url(""), do: []

  def parse_url({:system, env}) when is_binary(env) do
    parse_url(System.get_env(env) || "")
  end

  def parse_url(url) when is_binary(url) do
    info = url |> URI.decode() |> URI.parse()

    if is_nil(info.host) do
      # TODO:
      raise "url: #{inspect url}  message: `host is not present`"
    end

    destructure [username, password], (info.userinfo && String.split(info.userinfo, ":"))
    "/" <> database = info.path

    opts = [username: username,
            password: password,
            hostname: info.host,
            protocol: info.scheme,
            path:     info.path,
            port:     info.port]

    Enum.reject(opts, fn {_k, v} -> is_nil(v) end)
  end

end
