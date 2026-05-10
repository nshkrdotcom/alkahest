project_root = Path.expand("..", __DIR__)
repo_root = Path.expand("../..", project_root)

%{
  deps: %{
    alkahest_contracts: %{
      path: Path.join(repo_root, "apps/alkahest_contracts"),
      github: %{repo: "nshkrdotcom/alkahest", branch: "main", subdir: "apps/alkahest_contracts"},
      hex: "~> 0.1.0",
      default_order: [:path, :github, :hex],
      publish_order: [:hex]
    },
    alkahest_client: %{
      path: Path.join(repo_root, "apps/alkahest_client"),
      github: %{repo: "nshkrdotcom/alkahest", branch: "main", subdir: "apps/alkahest_client"},
      hex: "~> 0.1.0",
      default_order: [:path, :github, :hex],
      publish_order: [:hex]
    }
  }
}
