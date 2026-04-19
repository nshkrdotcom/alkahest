defmodule Alkahest.Contracts.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/nshkrdotcom/alkahest"

  def project do
    [
      app: :alkahest_contracts,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      build_path: "../../_build",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      deps: deps(),
      docs: docs(),
      description: description(),
      package: package(),
      dialyzer: dialyzer(),
      name: "Alkahest Contracts",
      source_url: @source_url,
      homepage_url: @source_url
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:protobuf, "~> 0.16.0"},
      {:grpc, "~> 0.11.5"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Reusable protobuf and gRPC workflow-control contracts for Alkahest."
  end

  defp docs do
    [
      main: "readme",
      name: "Alkahest Contracts",
      source_ref: "v#{@version}",
      source_url: @source_url,
      homepage_url: @source_url,
      assets: %{"assets" => "assets"},
      logo: "assets/alkahest.svg",
      extras: ["README.md", "CHANGELOG.md", "LICENSE"],
      groups_for_extras: [Project: ["README.md", "CHANGELOG.md", "LICENSE"]]
    ]
  end

  defp package do
    [
      name: "alkahest_contracts",
      description: description(),
      files: ~w(lib assets mix.exs README.md CHANGELOG.md LICENSE),
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      maintainers: ["nshkrdotcom"]
    ]
  end

  defp dialyzer do
    [plt_add_apps: [:mix, :ex_unit], plt_core_path: "../../_build/plts/core"]
  end
end
