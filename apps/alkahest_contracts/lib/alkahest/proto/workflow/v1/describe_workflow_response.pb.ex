defmodule Alkahest.Proto.Workflow.V1.DescribeWorkflowResponse do
  use Protobuf,
    full_name: "alkahest.workflow.v1.DescribeWorkflowResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field(:ref, 1, type: Alkahest.Proto.Workflow.V1.WorkflowRef)
  field(:status, 2, type: :string)
  field(:task_queue, 3, type: :string, json_name: "taskQueue")
  field(:metadata, 4, repeated: true, type: Alkahest.Proto.Workflow.V1.MetadataEntry)
  field(:error, 5, type: Alkahest.Proto.Workflow.V1.WorkflowError)
end
