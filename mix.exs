defmodule ESx.Mixfile do
  use Mix.Project

  @version "0.7.3"

  @description """
  A client for the Elasticsearch with Ecto, written in Elixir
  """

  def project do
    [
      app: :esx,
      version: @version,
      elixir: ">= 1.2.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      aliases: aliases(),
      description: @description,
      name: "ESx",
      xref: [
        exclude: [
          Ecto.Query,
          Ecto.Query.Builder,
          Ecto.Query.Builder.Filter,
          Ecto.Query.Builder.From,
          Ecto.Query.Builder.LimitOffset,
          Ecto.Query.Builder.OrderBy,
          JSX,
          Poison,
          :poolboy
        ]
      ],
      docs: [
        source_ref: "master",
        main: "ESx",
        canonical: "http://hexdocs.pm/esx",
        source_url: "https://github.com/ikeikeikeike/esx"
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison], mod: {ESx, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, ">= 0.7.0"},
      {:poison, ">= 1.2.0"},
      {:exjsx, ">= 3.0.0"},
      {:poolboy, ">= 1.0.0 and < 2.0.0"},
      {:ecto, ">= 1.1.0", optional: true},
      {:postgrex, ">= 0.0.0", only: [:dev, :test]},
      {:credo, ">= 0.0.0", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:earmark, ">= 0.0.0", only: :dev},
      {:inch_ex, ">= 0.0.0", only: :docs}
    ]
  end

  defp package do
    [
      maintainers: ["Tatsuo Ikeda / ikeikeikeike"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ikeikeikeike/esx"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [test: ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
