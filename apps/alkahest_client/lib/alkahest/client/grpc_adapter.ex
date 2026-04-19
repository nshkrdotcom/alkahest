defmodule Alkahest.Client.GRPCAdapter do
  @moduledoc "gRPC adapter for the Alkahest gateway service."
  @behaviour Alkahest.Client.Adapter

  alias Alkahest.Proto.Workflow.V1.WorkflowRuntimeGateway.Stub

  @impl true
  def start_workflow(request, opts), do: call(:start_workflow, request, opts)

  @impl true
  def signal_workflow(request, opts), do: call(:signal_workflow, request, opts)

  @impl true
  def query_workflow(request, opts), do: call(:query_workflow, request, opts)

  @impl true
  def cancel_workflow(request, opts), do: call(:cancel_workflow, request, opts)

  @impl true
  def describe_workflow(request, opts), do: call(:describe_workflow, request, opts)

  @impl true
  def fetch_workflow_history_ref(request, opts),
    do: call(:fetch_workflow_history_ref, request, opts)

  defp call(function, request, opts) do
    with {:ok, channel} <- connect(opts) do
      apply(Stub, function, [channel, request, rpc_opts(opts)])
    end
  end

  defp connect(opts) do
    opts
    |> Keyword.fetch(:endpoint)
    |> case do
      {:ok, endpoint} -> GRPC.Stub.connect(endpoint, channel_opts(opts))
      :error -> {:error, :missing_gateway_endpoint}
    end
  end

  defp channel_opts(opts), do: Keyword.get(opts, :channel_opts, [])
  defp rpc_opts(opts), do: Keyword.get(opts, :rpc_opts, [])
end
