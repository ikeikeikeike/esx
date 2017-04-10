defmodule ESx.Mixfile do
  use Mix.Project

  @description """
  A client for the Elasticsearch, written in Elixir
  """

  def project do
    [app: :esx,
     version: "0.5.3",
     elixir: ">= 1.2.0",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     aliases: aliases(),
     description: @description,
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison, :ecto, :postgrex], mod: {ESx, []}]
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
      {:credo, "~> 0.7", only: [:dev, :test]},
      {:earmark, ">= 0.0.0", only: :dev},
      {:ex_doc, "~> 0.10", only: :dev},
      {:inch_ex, only: :docs},
    ]
  end

  defp package do
    [
      maintainers: ["Tatsuo Ikeda / ikeikeikeike"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ikeikeikeike/esx"},
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    ["test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end

end
