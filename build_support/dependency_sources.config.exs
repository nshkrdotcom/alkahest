%{
  deps: %{
    alkahest_contracts: %{
      path: "apps/alkahest_contracts",
      github: %{repo: "nshkrdotcom/alkahest", branch: "main", subdir: "apps/alkahest_contracts"},
      hex: "~> 0.1.0",
      default_order: [:path, :github, :hex],
      publish_order: [:hex]
    },
    alkahest_client: %{
      path: "apps/alkahest_client",
      github: %{repo: "nshkrdotcom/alkahest", branch: "main", subdir: "apps/alkahest_client"},
      hex: "~> 0.1.0",
      default_order: [:path, :github, :hex],
      publish_order: [:hex]
    },
    alkahest_test_support: %{
      path: "apps/alkahest_test_support",
      github: %{
        repo: "nshkrdotcom/alkahest",
        branch: "main",
        subdir: "apps/alkahest_test_support"
      },
      hex: "~> 0.1.0",
      default_order: [:path, :github, :hex],
      publish_order: [:hex]
    }
  }
}
