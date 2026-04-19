defmodule Alkahest.TestSupport.FakeAdapter do
  @moduledoc "Deterministic adapter for tests that need Alkahest client behavior without a live gateway."
  @behaviour Alkahest.Client.Adapter

  alias Alkahest.Proto.Workflow.V1.CancelWorkflowResponse
  alias Alkahest.Proto.Workflow.V1.DescribeWorkflowResponse
  alias Alkahest.Proto.Workflow.V1.FetchWorkflowHistoryRefResponse
  alias Alkahest.Proto.Workflow.V1.QueryWorkflowResponse
  alias Alkahest.Proto.Workflow.V1.SignalWorkflowResponse
  alias Alkahest.Proto.Workflow.V1.StartWorkflowRequest
  alias Alkahest.Proto.Workflow.V1.StartWorkflowResponse
  alias Alkahest.Proto.Workflow.V1.WorkflowRef

  @impl true
  def start_workflow(%StartWorkflowRequest{} = request, opts) do
    notify(opts, {:start_workflow, request})
    {:ok, %StartWorkflowResponse{ref: ref(request), status: "started"}}
  end

  @impl true
  def signal_workflow(request, opts) do
    notify(opts, {:signal_workflow, request})
    {:ok, %SignalWorkflowResponse{ref: request.ref, status: "signaled"}}
  end

  @impl true
  def query_workflow(request, opts) do
    notify(opts, {:query_workflow, request})

    {:ok,
     %QueryWorkflowResponse{ref: request.ref, result_json: Keyword.get(opts, :result_json, "{}")}}
  end

  @impl true
  def cancel_workflow(request, opts) do
    notify(opts, {:cancel_workflow, request})
    {:ok, %CancelWorkflowResponse{ref: request.ref, status: "cancel_requested"}}
  end

  @impl true
  def describe_workflow(request, opts) do
    notify(opts, {:describe_workflow, request})

    {:ok,
     %DescribeWorkflowResponse{
       ref: request.ref,
       status: "running",
       task_queue: Keyword.get(opts, :task_queue, "test")
     }}
  end

  @impl true
  def fetch_workflow_history_ref(request, opts) do
    notify(opts, {:fetch_workflow_history_ref, request})

    {:ok,
     %FetchWorkflowHistoryRefResponse{
       ref: request.ref,
       history_uri: "temporal://#{request.ref.workflow_id}"
     }}
  end

  defp notify(opts, message) do
    case Keyword.get(opts, :test_pid) do
      nil -> :ok
      pid -> send(pid, message)
    end
  end

  defp ref(request) do
    %WorkflowRef{namespace: request.namespace, workflow_id: request.workflow_id, run_id: ""}
  end
end
