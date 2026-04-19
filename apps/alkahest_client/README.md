# Alkahest Client

Elixir client facade for the Alkahest workflow runtime gateway. This package talks to Alkahest's gateway contract; it does not host Temporal workers.

## gRPC supervisor

`Alkahest.Client` starts `GRPC.Client.Supervisor` idempotently before opening a gRPC channel. This keeps scripts and local examples usable without manual setup.

OTP applications can still supervise the gRPC client supervisor directly:

```elixir
children = [
  {GRPC.Client.Supervisor, []}
]
```

## Example call

```elixir
alias Alkahest.Client
alias Alkahest.Proto.Workflow.V1.StartWorkflowRequest

request = %StartWorkflowRequest{
  namespace: "default",
  workflow_id: "example-1",
  workflow_type: "ExecutionLifecycleWorkflow",
  task_queue: "alkahest.dev",
  input_json: ~s({"ok":true})
}

Client.start_workflow(request, endpoint: "127.0.0.1:9090")
```

For a full live run, use `examples/run_all.sh` from the repository root.
