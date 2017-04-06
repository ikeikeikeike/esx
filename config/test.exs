use Mix.Config

config :esx, ESx.Test.Support.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "esx_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
  # priv: "test/support"

config :esx, :ecto_repos,
  [ESx.Test.Support.Repo]
