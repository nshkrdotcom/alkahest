defmodule Alkahest.TestSupport.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/nshkrdotcom/alkahest"

  def project do
    [
      app: :alkahest_test_support,
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
      name: "Alkahest Test Support",
      source_url: @source_url,
      homepage_url: @source_url
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:alkahest_contracts, path: "../alkahest_contracts"},
      {:alkahest_client, path: "../alkahest_client"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Test support for downstream Alkahest client integrations."
  end

  defp docs do
    [
      main: "readme",
      name: "Alkahest Test Support",
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
      name: "alkahest_test_support",
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
