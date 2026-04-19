defmodule Alkahest.Proto.Workflow.V1.WorkflowRef do
  use Protobuf,
    full_name: "alkahest.workflow.v1.WorkflowRef",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field(:namespace, 1, type: :string)
  field(:workflow_id, 2, type: :string, json_name: "workflowId")
  field(:run_id, 3, type: :string, json_name: "runId")
end
