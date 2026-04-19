defmodule Alkahest.Proto.Workflow.V1.MetadataEntry do
  use Protobuf,
    full_name: "alkahest.workflow.v1.MetadataEntry",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field(:key, 1, type: :string)
  field(:value, 2, type: :string)
end
