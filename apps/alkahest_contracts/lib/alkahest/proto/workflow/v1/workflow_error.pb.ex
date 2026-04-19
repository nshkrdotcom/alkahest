defmodule Alkahest.Proto.Workflow.V1.WorkflowError do
  use Protobuf,
    full_name: "alkahest.workflow.v1.WorkflowError",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field(:code, 1, type: :string)
  field(:message, 2, type: :string)
  field(:retryable, 3, type: :bool)
end
