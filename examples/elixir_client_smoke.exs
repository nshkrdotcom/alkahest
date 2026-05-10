defmodule Alkahest.Examples.ElixirClientSmoke do
  @moduledoc false

  alias Alkahest.Client
  alias Alkahest.Proto.Workflow.V1.DescribeWorkflowRequest
  alias Alkahest.Proto.Workflow.V1.FetchWorkflowHistoryRefRequest
  alias Alkahest.Proto.Workflow.V1.StartWorkflowRequest

  @poll_interval_ms 500
  @default_endpoint "127.0.0.1:9090"
  @default_namespace "default"
  @default_task_queue "alkahest.dev"
  @default_workflow_type "ExecutionLifecycleWorkflow"
  @default_timeout_ms 15_000

  def run(argv \\ System.argv()) do
    config = config!(argv)
    endpoint = config[:endpoint]
    namespace = config[:namespace]
    task_queue = config[:task_queue]
    workflow_type = config[:workflow_type]
    workflow_id = "alkahest-example-#{System.unique_integer([:positive])}"
    timeout_ms = config[:timeout_ms]

    opts = [endpoint: endpoint, rpc_opts: [timeout: timeout_ms]]

    print("starting #{workflow_type} as #{workflow_id} through #{endpoint}")

    start_response =
      %StartWorkflowRequest{
        namespace: namespace,
        workflow_id: workflow_id,
        workflow_type: workflow_type,
        task_queue: task_queue,
        input_json: ~s({"source":"alkahest-example","ok":true})
      }
      |> Client.start_workflow(opts)
      |> unwrap!("StartWorkflow")

    print("started run #{start_response.ref.run_id}")

    describe_response =
      start_response.ref
      |> wait_until_completed(opts, monotonic_deadline(timeout_ms))

    print("workflow status #{describe_response.status}")

    history_response =
      %FetchWorkflowHistoryRefRequest{ref: start_response.ref}
      |> Client.fetch_workflow_history_ref(opts)
      |> unwrap!("FetchWorkflowHistoryRef")

    unless String.starts_with?(history_response.history_uri, "temporal://") do
      abort!(
        "FetchWorkflowHistoryRef returned invalid URI #{inspect(history_response.history_uri)}"
      )
    end

    print("history ref #{history_response.history_uri}")
    print("OK")
  end

  defp wait_until_completed(ref, opts, deadline_ms) do
    response =
      %DescribeWorkflowRequest{ref: ref}
      |> Client.describe_workflow(opts)
      |> unwrap!("DescribeWorkflow")

    case response.status do
      "Completed" ->
        response

      status ->
        if System.monotonic_time(:millisecond) >= deadline_ms do
          abort!("workflow did not complete before timeout; last status was #{inspect(status)}")
        end

        Process.sleep(@poll_interval_ms)
        wait_until_completed(ref, opts, deadline_ms)
    end
  end

  defp unwrap!({:ok, %{error: nil} = response}, _label), do: response

  defp unwrap!({:ok, %{error: error}}, label) when not is_nil(error) do
    abort!("#{label} returned gateway error #{inspect(error)}")
  end

  defp unwrap!({:error, reason}, label), do: abort!("#{label} failed: #{inspect(reason)}")

  defp monotonic_deadline(timeout_ms), do: System.monotonic_time(:millisecond) + timeout_ms

  defp config!(argv) do
    {opts, rest, invalid} =
      OptionParser.parse(argv,
        strict: [
          endpoint: :string,
          namespace: :string,
          task_queue: :string,
          workflow_type: :string,
          timeout_ms: :integer
        ]
      )

    case {rest, invalid} do
      {[], []} ->
        timeout_ms = Keyword.get(opts, :timeout_ms, @default_timeout_ms)

        if timeout_ms <= 0 do
          abort!("--timeout-ms must be greater than 0")
        end

        [
          endpoint: Keyword.get(opts, :endpoint, @default_endpoint),
          namespace: Keyword.get(opts, :namespace, @default_namespace),
          task_queue: Keyword.get(opts, :task_queue, @default_task_queue),
          workflow_type: Keyword.get(opts, :workflow_type, @default_workflow_type),
          timeout_ms: timeout_ms
        ]

      {_, _} ->
        abort!("unsupported arguments: #{inspect(rest ++ Enum.map(invalid, &elem(&1, 0)))}")
    end
  end

  defp print(message), do: IO.puts("[alkahest-example] #{message}")

  defp abort!(message) do
    IO.puts(:stderr, "[alkahest-example] ERROR: #{message}")
    System.halt(1)
  end
end

Alkahest.Examples.ElixirClientSmoke.run()
