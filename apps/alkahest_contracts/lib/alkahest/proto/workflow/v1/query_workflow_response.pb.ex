defmodule Alkahest.Proto.Workflow.V1.QueryWorkflowResponse do
  use Protobuf,
    full_name: "alkahest.workflow.v1.QueryWorkflowResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field(:ref, 1, type: Alkahest.Proto.Workflow.V1.WorkflowRef)
  field(:result_json, 2, type: :string, json_name: "resultJson")
  field(:error, 3, type: Alkahest.Proto.Workflow.V1.WorkflowError)
end
