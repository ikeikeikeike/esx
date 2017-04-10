use Mix.Config

config :esx, ESx.Model,
  protocol: "http",
  host: "localhost",
  port: 9200,
  trace: true
