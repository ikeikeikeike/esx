use Mix.Config

config :esx, ESx.Model,
  protocol: "http",
  host: "127.0.0.1",
  port: 9200,
  trace: true,
  options: [
    max_retries: 5,
    selector: ESx.Transport.Selector.Random
  ]
