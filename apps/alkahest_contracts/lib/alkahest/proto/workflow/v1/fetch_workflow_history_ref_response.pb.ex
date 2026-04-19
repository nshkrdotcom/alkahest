defmodule Alkahest.Proto.Workflow.V1.FetchWorkflowHistoryRefResponse do
  use Protobuf,
    full_name: "alkahest.workflow.v1.FetchWorkflowHistoryRefResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field(:ref, 1, type: Alkahest.Proto.Workflow.V1.WorkflowRef)
  field(:history_uri, 2, type: :string, json_name: "historyUri")
  field(:error, 3, type: Alkahest.Proto.Workflow.V1.WorkflowError)
end
