defmodule Alkahest.ContractsTest do
  use ExUnit.Case, async: true

  alias Alkahest.Contracts
  alias Alkahest.Proto.Workflow.V1.StartWorkflowRequest

  test "builds deterministic metadata entries" do
    assert [%{key: "a", value: "1"}, %{key: "b", value: "two"}] =
             Contracts.metadata(%{b: :two, a: 1})
  end

  test "validates start workflow required fields" do
    assert {:ok, %StartWorkflowRequest{workflow_id: "wf-1"}} =
             Contracts.start_workflow_request(%{
               namespace: "default",
               workflow_id: "wf-1",
               workflow_type: "ExecutionLifecycleWorkflow",
               task_queue: "mezzanine.execution",
               idempotency_key: "idem-1",
               trace_id: "trace-1"
             })

    assert {:error, {:missing, :workflow_id}} =
             Contracts.start_workflow_request(%{
               namespace: "default",
               workflow_type: "ExecutionLifecycleWorkflow",
               task_queue: "mezzanine.execution",
               idempotency_key: "idem-1",
               trace_id: "trace-1"
             })
  end

  test "protobuf DTOs encode and decode" do
    {:ok, request} =
      Contracts.start_workflow_request(%{
        namespace: "default",
        workflow_id: "wf-1",
        workflow_type: "ExecutionLifecycleWorkflow",
        task_queue: "mezzanine.execution",
        idempotency_key: "idem-1",
        trace_id: "trace-1"
      })

    encoded = StartWorkflowRequest.encode(request)
    assert %StartWorkflowRequest{workflow_id: "wf-1"} = StartWorkflowRequest.decode(encoded)
  end
end
