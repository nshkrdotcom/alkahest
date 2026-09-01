if bootstrap = System.get_env("MIX_WORKSPACE_OPS_BOOTSTRAP"), do: Code.require_file(bootstrap)

defmodule Alkahest.Client.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/nshkrdotcom/alkahest"

  def project do
    [
      app: :alkahest_client,
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
      name: "Alkahest Client",
      source_url: @source_url,
      homepage_url: @source_url
    ]
  end

  def application do
    [extra_applications: [:logger, :grpc]]
  end

  defp deps do
    [
      workspace_dep({:alkahest_contracts, "~> 0.1.0"}),
      {:grpc, "~> 0.11.5"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false}
    ]
  end

  defp workspace_dep(committed) do
    if function_exported?(MixWorkspaceOpsBootstrap, :dep, 2),
      do: apply(MixWorkspaceOpsBootstrap, :dep, [committed, __DIR__]),
      else: committed
  end

  defp description do
    "Elixir gRPC client facade for the Alkahest Temporal gateway contract."
  end

  defp docs do
    [
      main: "readme",
      name: "Alkahest Client",
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
      name: "alkahest_client",
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
