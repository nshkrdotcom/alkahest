defmodule Alkahest.Proto.Workflow.V1.WorkflowRuntimeGateway.Service do
  use GRPC.Service,
    name: "alkahest.workflow.v1.WorkflowRuntimeGateway",
    protoc_gen_elixir_version: "0.16.0"

  rpc(
    :StartWorkflow,
    Alkahest.Proto.Workflow.V1.StartWorkflowRequest,
    Alkahest.Proto.Workflow.V1.StartWorkflowResponse
  )

  rpc(
    :SignalWorkflow,
    Alkahest.Proto.Workflow.V1.SignalWorkflowRequest,
    Alkahest.Proto.Workflow.V1.SignalWorkflowResponse
  )

  rpc(
    :QueryWorkflow,
    Alkahest.Proto.Workflow.V1.QueryWorkflowRequest,
    Alkahest.Proto.Workflow.V1.QueryWorkflowResponse
  )

  rpc(
    :CancelWorkflow,
    Alkahest.Proto.Workflow.V1.CancelWorkflowRequest,
    Alkahest.Proto.Workflow.V1.CancelWorkflowResponse
  )

  rpc(
    :DescribeWorkflow,
    Alkahest.Proto.Workflow.V1.DescribeWorkflowRequest,
    Alkahest.Proto.Workflow.V1.DescribeWorkflowResponse
  )

  rpc(
    :FetchWorkflowHistoryRef,
    Alkahest.Proto.Workflow.V1.FetchWorkflowHistoryRefRequest,
    Alkahest.Proto.Workflow.V1.FetchWorkflowHistoryRefResponse
  )
end

defmodule Alkahest.Proto.Workflow.V1.WorkflowRuntimeGateway.Stub do
  use GRPC.Stub, service: Alkahest.Proto.Workflow.V1.WorkflowRuntimeGateway.Service
end
