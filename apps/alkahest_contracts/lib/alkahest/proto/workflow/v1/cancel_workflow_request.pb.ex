defmodule Alkahest.Proto.Workflow.V1.CancelWorkflowRequest do
  use Protobuf,
    full_name: "alkahest.workflow.v1.CancelWorkflowRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field(:ref, 1, type: Alkahest.Proto.Workflow.V1.WorkflowRef)
  field(:reason, 2, type: :string)
  field(:metadata, 3, repeated: true, type: Alkahest.Proto.Workflow.V1.MetadataEntry)
  field(:trace_id, 4, type: :string, json_name: "traceId")
end
