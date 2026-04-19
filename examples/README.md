# Alkahest Live Examples

These examples prove the runnable local path:

```text
Elixir Alkahest.Client
  -> Alkahest gRPC gateway
  -> official Temporal Go SDK
  -> Temporal dev server
  -> official-SDK sample worker
```

They are operational examples, not default CI tests. They start local processes and expect a developer machine with Temporal tooling installed.

## Prerequisites

- Elixir and Mix
- Go
- `temporal` CLI
- `protoc` and the Go/Elixir protobuf plugins if regenerating code

Install repo dependencies first:

```bash
mix deps.get
scripts/dev/install-go-temporal-tools.sh
```

## Run Everything

From the repository root:

```bash
examples/run_all.sh
```

The runner:

- reuses an existing Temporal dev server on `127.0.0.1:7233`, or starts one
- reuses an existing Alkahest gateway on `127.0.0.1:9090`, or starts one
- starts the sample Go worker on task queue `alkahest.dev`
- runs `examples/elixir_client_smoke.exs`
- stops only the processes it started

Expected final output:

```text
[alkahest-example] workflow status Completed
[alkahest-example] history ref temporal://default/...
[alkahest-example] OK
Alkahest live example completed successfully.
```

## Configuration

Environment variables:

- `TEMPORAL_ADDRESS`, default `127.0.0.1:7233`
- `TEMPORAL_NAMESPACE`, default `default`
- `TEMPORAL_UI_PORT`, default `8233`
- `ALKAHEST_GATEWAY_ENDPOINT`, default `127.0.0.1:9090`
- `ALKAHEST_TASK_QUEUE`, default `alkahest.dev`
- `ALKAHEST_EXAMPLE_TIMEOUT_MS`, default `15000`
- `ALKAHEST_EXAMPLE_LOG_DIR`, default temporary directory

## Supervisor Behavior

`Alkahest.Client` starts `GRPC.Client.Supervisor` automatically before opening a gRPC channel. Downstream applications can still put `{GRPC.Client.Supervisor, []}` in their own supervision tree when they want explicit ownership.

