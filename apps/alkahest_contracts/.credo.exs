%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/"],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/lib/alkahest/proto/workflow/v1/.*\.pb\.ex$"]
      },
      checks: [
        {Credo.Check.Readability.StrictModuleLayout, false}
      ]
    }
  ]
}
