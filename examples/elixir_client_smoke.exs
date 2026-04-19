defmodule Alkahest.Examples.ElixirClientSmoke do
  @moduledoc false

  alias Alkahest.Client
  alias Alkahest.Proto.Workflow.V1.DescribeWorkflowRequest
  alias Alkahest.Proto.Workflow.V1.FetchWorkflowHistoryRefRequest
  alias Alkahest.Proto.Workflow.V1.StartWorkflowRequest

  @poll_interval_ms 500

  def run do
    endpoint = env("ALKAHEST_GATEWAY_ENDPOINT", "127.0.0.1:9090")
    namespace = env("TEMPORAL_NAMESPACE", "default")
    task_queue = env("ALKAHEST_TASK_QUEUE", "alkahest.dev")
    workflow_type = env("ALKAHEST_WORKFLOW_TYPE", "ExecutionLifecycleWorkflow")
    workflow_id = "alkahest-example-#{System.unique_integer([:positive])}"
    timeout_ms = env_int("ALKAHEST_EXAMPLE_TIMEOUT_MS", 15_000)

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
      abort!("FetchWorkflowHistoryRef returned invalid URI #{inspect(history_response.history_uri)}")
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

  defp env(name, fallback), do: System.get_env(name, fallback)

  defp env_int(name, fallback) do
    case Integer.parse(env(name, Integer.to_string(fallback))) do
      {value, ""} when value > 0 -> value
      _other -> fallback
    end
  end

  defp print(message), do: IO.puts("[alkahest-example] #{message}")

  defp abort!(message) do
    IO.puts(:stderr, "[alkahest-example] ERROR: #{message}")
    System.halt(1)
  end
end

Alkahest.Examples.ElixirClientSmoke.run()

