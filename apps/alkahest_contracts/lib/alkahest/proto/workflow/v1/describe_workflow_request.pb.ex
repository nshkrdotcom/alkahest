defmodule Alkahest.Proto.Workflow.V1.DescribeWorkflowRequest do
  use Protobuf,
    full_name: "alkahest.workflow.v1.DescribeWorkflowRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field(:ref, 1, type: Alkahest.Proto.Workflow.V1.WorkflowRef)
  field(:trace_id, 2, type: :string, json_name: "traceId")
end
