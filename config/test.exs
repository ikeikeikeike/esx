import Config

config :esx, ESx.Model,
  repo: ESx.Test.Support.Repo,
  protocol: "http",
  host: "127.0.0.1",
  port: 9200,
  trace: true

config :esx, ESx.Test.Support.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "esx_dev",
  username: "postgres",
  password: "postgres",
  hostname: "127.0.0.1",
  pool: Ecto.Adapters.SQL.Sandbox,
  timeout: 60_000,
  pool_timeout: 60_000,
  ownership_timeout: 60_000

# priv: "test/support"

config :esx, :ecto_repos, [ESx.Test.Support.Repo]
