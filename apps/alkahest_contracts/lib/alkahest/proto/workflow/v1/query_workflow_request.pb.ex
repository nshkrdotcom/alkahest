defmodule Alkahest.Proto.Workflow.V1.QueryWorkflowRequest do
  use Protobuf,
    full_name: "alkahest.workflow.v1.QueryWorkflowRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field(:ref, 1, type: Alkahest.Proto.Workflow.V1.WorkflowRef)
  field(:query_name, 2, type: :string, json_name: "queryName")
  field(:payload_json, 3, type: :string, json_name: "payloadJson")
  field(:metadata, 4, repeated: true, type: Alkahest.Proto.Workflow.V1.MetadataEntry)
  field(:trace_id, 5, type: :string, json_name: "traceId")
end
