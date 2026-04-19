defmodule Alkahest.Proto.Workflow.V1.StartWorkflowResponse do
  use Protobuf,
    full_name: "alkahest.workflow.v1.StartWorkflowResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field(:ref, 1, type: Alkahest.Proto.Workflow.V1.WorkflowRef)
  field(:status, 2, type: :string)
  field(:error, 3, type: Alkahest.Proto.Workflow.V1.WorkflowError)
end
