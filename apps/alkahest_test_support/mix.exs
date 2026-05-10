unless Code.ensure_loaded?(DependencySources) do
  Code.require_file("build_support/dependency_sources.exs", __DIR__)
end

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
      DependencySources.dep(:alkahest_contracts, __DIR__),
      DependencySources.dep(:alkahest_client, __DIR__),
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
      files: ~w(lib assets build_support mix.exs README.md CHANGELOG.md LICENSE),
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      maintainers: ["nshkrdotcom"]
    ]
  end

  defp dialyzer do
    [plt_add_apps: [:mix, :ex_unit], plt_core_path: "../../_build/plts/core"]
  end
end
