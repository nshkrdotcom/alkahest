defmodule Alkahest.Client do
  @moduledoc "Reusable Elixir facade for Alkahest workflow-control operations."

  alias Alkahest.Client.Adapter
  alias Alkahest.Client.GRPCAdapter
  alias Alkahest.Proto.Workflow.V1.CancelWorkflowRequest
  alias Alkahest.Proto.Workflow.V1.DescribeWorkflowRequest
  alias Alkahest.Proto.Workflow.V1.FetchWorkflowHistoryRefRequest
  alias Alkahest.Proto.Workflow.V1.QueryWorkflowRequest
  alias Alkahest.Proto.Workflow.V1.SignalWorkflowRequest
  alias Alkahest.Proto.Workflow.V1.StartWorkflowRequest

  @type opts :: keyword()

  @spec start_workflow(StartWorkflowRequest.t(), opts()) :: Adapter.rpc_result(term())
  def start_workflow(request, opts \\ []), do: adapter(opts).start_workflow(request, opts)

  @spec signal_workflow(SignalWorkflowRequest.t(), opts()) :: Adapter.rpc_result(term())
  def signal_workflow(request, opts \\ []), do: adapter(opts).signal_workflow(request, opts)

  @spec query_workflow(QueryWorkflowRequest.t(), opts()) :: Adapter.rpc_result(term())
  def query_workflow(request, opts \\ []), do: adapter(opts).query_workflow(request, opts)

  @spec cancel_workflow(CancelWorkflowRequest.t(), opts()) :: Adapter.rpc_result(term())
  def cancel_workflow(request, opts \\ []), do: adapter(opts).cancel_workflow(request, opts)

  @spec describe_workflow(DescribeWorkflowRequest.t(), opts()) :: Adapter.rpc_result(term())
  def describe_workflow(request, opts \\ []), do: adapter(opts).describe_workflow(request, opts)

  @spec fetch_workflow_history_ref(FetchWorkflowHistoryRefRequest.t(), opts()) ::
          Adapter.rpc_result(term())
  def fetch_workflow_history_ref(request, opts \\ []),
    do: adapter(opts).fetch_workflow_history_ref(request, opts)

  defp adapter(opts), do: Keyword.get(opts, :adapter, GRPCAdapter)
end
