# Alkahest Temporal Gateway

This service implements the Alkahest workflow-control gRPC contract using the official Temporal Go SDK.

It is intentionally separate from Elixir:

- Elixir calls `Alkahest.Client`.
- `Alkahest.Client` calls this gateway over gRPC.
- This gateway calls Temporal Frontend through the official Go SDK.
- external workers poll task queues through the official Go SDK.

## Setup

```bash
../../scripts/dev/install-go-temporal-tools.sh
../../scripts/dev/gen-proto.sh
go test ./...
```

`gen-proto.sh` regenerates both this service's Go bindings and the Elixir contract modules in `apps/alkahest_contracts`.

## Run locally

Start Temporal:

```bash
temporal server start-dev
```

Start the gateway:

```bash
go run ./cmd/alkahest-temporal-gateway
```

Start the sample worker:

```bash
go run ./cmd/alkahest-temporal-worker
```

Or run the complete local live example from the repository root:

```bash
examples/run_all.sh
```
