defmodule Alkahest.TestSupport.FakeAdapterTest do
  use ExUnit.Case, async: true

  alias Alkahest.Client
  alias Alkahest.Proto.Workflow.V1.StartWorkflowRequest
  alias Alkahest.TestSupport.FakeAdapter

  test "fake adapter records start workflow calls" do
    request = %StartWorkflowRequest{namespace: "default", workflow_id: "wf-1"}

    assert {:ok, response} =
             Client.start_workflow(request, adapter: FakeAdapter, test_pid: self())

    assert response.ref.workflow_id == "wf-1"
    assert_receive {:start_workflow, ^request}
  end
end
