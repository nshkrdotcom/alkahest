defmodule Alkahest.Proto.Workflow.V1.StartWorkflowRequest do
  use Protobuf,
    full_name: "alkahest.workflow.v1.StartWorkflowRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field(:namespace, 1, type: :string)
  field(:workflow_id, 2, type: :string, json_name: "workflowId")
  field(:workflow_type, 3, type: :string, json_name: "workflowType")
  field(:task_queue, 4, type: :string, json_name: "taskQueue")
  field(:input_json, 5, type: :string, json_name: "inputJson")
  field(:metadata, 6, repeated: true, type: Alkahest.Proto.Workflow.V1.MetadataEntry)
  field(:idempotency_key, 7, type: :string, json_name: "idempotencyKey")
  field(:trace_id, 8, type: :string, json_name: "traceId")
end
