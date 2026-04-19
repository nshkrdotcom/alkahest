defmodule Alkahest.ClientTest do
  use ExUnit.Case, async: true

  alias Alkahest.Client
  alias Alkahest.Proto.Workflow.V1.StartWorkflowRequest
  alias Alkahest.Proto.Workflow.V1.StartWorkflowResponse
  alias Alkahest.Proto.Workflow.V1.WorkflowRef

  defmodule FakeAdapter do
    @behaviour Alkahest.Client.Adapter

    @impl true
    def start_workflow(%StartWorkflowRequest{workflow_id: workflow_id}, opts) do
      send(Keyword.fetch!(opts, :test_pid), {:start_workflow, workflow_id})

      {:ok,
       %StartWorkflowResponse{
         ref: %WorkflowRef{namespace: "default", workflow_id: workflow_id},
         status: "started"
       }}
    end

    @impl true
    def signal_workflow(_request, _opts), do: {:error, :not_used}

    @impl true
    def query_workflow(_request, _opts), do: {:error, :not_used}

    @impl true
    def cancel_workflow(_request, _opts), do: {:error, :not_used}

    @impl true
    def describe_workflow(_request, _opts), do: {:error, :not_used}

    @impl true
    def fetch_workflow_history_ref(_request, _opts), do: {:error, :not_used}
  end

  test "delegates workflow start to configured adapter" do
    request = %StartWorkflowRequest{workflow_id: "wf-1"}

    assert {:ok, %StartWorkflowResponse{status: "started"}} =
             Client.start_workflow(request, adapter: FakeAdapter, test_pid: self())

    assert_receive {:start_workflow, "wf-1"}
  end

  test "grpc adapter requires an endpoint" do
    assert {:error, :missing_gateway_endpoint} = Client.start_workflow(%StartWorkflowRequest{})
  end
end
