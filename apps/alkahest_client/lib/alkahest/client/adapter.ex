defmodule Alkahest.Client.Adapter do
  @moduledoc "Behaviour implemented by Alkahest workflow-control client adapters."

  alias Alkahest.Proto.Workflow.V1.CancelWorkflowRequest
  alias Alkahest.Proto.Workflow.V1.CancelWorkflowResponse
  alias Alkahest.Proto.Workflow.V1.DescribeWorkflowRequest
  alias Alkahest.Proto.Workflow.V1.DescribeWorkflowResponse
  alias Alkahest.Proto.Workflow.V1.FetchWorkflowHistoryRefRequest
  alias Alkahest.Proto.Workflow.V1.FetchWorkflowHistoryRefResponse
  alias Alkahest.Proto.Workflow.V1.QueryWorkflowRequest
  alias Alkahest.Proto.Workflow.V1.QueryWorkflowResponse
  alias Alkahest.Proto.Workflow.V1.SignalWorkflowRequest
  alias Alkahest.Proto.Workflow.V1.SignalWorkflowResponse
  alias Alkahest.Proto.Workflow.V1.StartWorkflowRequest
  alias Alkahest.Proto.Workflow.V1.StartWorkflowResponse

  @type rpc_result(response) :: {:ok, response} | {:error, term()}

  @callback start_workflow(StartWorkflowRequest.t(), keyword()) ::
              rpc_result(StartWorkflowResponse.t())
  @callback signal_workflow(SignalWorkflowRequest.t(), keyword()) ::
              rpc_result(SignalWorkflowResponse.t())
  @callback query_workflow(QueryWorkflowRequest.t(), keyword()) ::
              rpc_result(QueryWorkflowResponse.t())
  @callback cancel_workflow(CancelWorkflowRequest.t(), keyword()) ::
              rpc_result(CancelWorkflowResponse.t())
  @callback describe_workflow(DescribeWorkflowRequest.t(), keyword()) ::
              rpc_result(DescribeWorkflowResponse.t())
  @callback fetch_workflow_history_ref(FetchWorkflowHistoryRefRequest.t(), keyword()) ::
              rpc_result(FetchWorkflowHistoryRefResponse.t())
end
