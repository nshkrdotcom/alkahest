defmodule Alkahest.Proto.Workflow.V1.WorkflowRuntimeGateway.Service do
  @moduledoc "gRPC service definition for the Alkahest workflow runtime gateway."
  use GRPC.Service,
    name: "alkahest.workflow.v1.WorkflowRuntimeGateway",
    protoc_gen_elixir_version: "0.16.0"

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

  rpc(:StartWorkflow, StartWorkflowRequest, StartWorkflowResponse)
  rpc(:SignalWorkflow, SignalWorkflowRequest, SignalWorkflowResponse)
  rpc(:QueryWorkflow, QueryWorkflowRequest, QueryWorkflowResponse)
  rpc(:CancelWorkflow, CancelWorkflowRequest, CancelWorkflowResponse)
  rpc(:DescribeWorkflow, DescribeWorkflowRequest, DescribeWorkflowResponse)
  rpc(:FetchWorkflowHistoryRef, FetchWorkflowHistoryRefRequest, FetchWorkflowHistoryRefResponse)
end

defmodule Alkahest.Proto.Workflow.V1.WorkflowRuntimeGateway.Stub do
  @moduledoc "gRPC client stub for the Alkahest workflow runtime gateway."
  use GRPC.Stub, service: Alkahest.Proto.Workflow.V1.WorkflowRuntimeGateway.Service
end
