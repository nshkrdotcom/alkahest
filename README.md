# Alkahest

<p align="center">
  <img src="assets/alkahest.svg" alt="Alkahest logo" width="200" height="200" />
</p>

Alkahest is a reusable Temporal facade substrate for durable distributed agentic systems. It gives Elixir applications a stable workflow-control contract without forcing the BEAM to host Temporal workers or depend on immature Elixir Temporal SDK runtime machinery.

Alkahest is not an umbrella app. It is a monorepo of separate Mix projects under `apps/`, coordinated by Blitz.

## Architecture

```text
Elixir application
  -> Alkahest.Client / domain wrapper
    -> Alkahest gRPC gateway contract
      -> temporal_gateway service using the official Temporal Go SDK
        -> Temporal Frontend over native gRPC/protobuf

external official-SDK workers
  -> Temporal Frontend task queues
  -> approved system APIs for side effects
```

The reusable boundary is intentionally narrow:

- start workflow
- signal workflow
- query workflow
- cancel workflow
- describe workflow
- fetch workflow history reference

Alkahest does not reimplement Temporal. The official SDK owns Temporal protocol details, worker polling, replay semantics, task tokens, activity execution, and Temporal server compatibility.

## Projects

- `apps/alkahest_contracts`: protobuf/gRPC contract modules, workflow DTOs, validation, and shared error shapes.
- `apps/alkahest_client`: Elixir client facade that calls the Alkahest gateway over gRPC.
- `apps/alkahest_test_support`: reusable fake adapter and fixtures for downstream tests.
- `services/temporal_gateway`: Go service and worker skeleton using the official Temporal Go SDK.

## Installation

Use the client package from this monorepo in downstream Elixir apps:

```elixir
def deps do
  [
    {:alkahest_client, github: "nshkrdotcom/alkahest", subdir: "apps/alkahest_client"}
  ]
end
```

For active sibling development:

```elixir
def deps do
  [
    {:alkahest_client, path: "../alkahest/apps/alkahest_client"}
  ]
end
```

## Development setup

Install Elixir deps:

```bash
mix deps.get
```

Install Go Temporal tooling and protobuf generators:

```bash
scripts/dev/install-go-temporal-tools.sh
```

Regenerate Go protobuf bindings:

```bash
scripts/dev/gen-proto.sh
```

Run all checks:

```bash
mix ci
```

Or with `just`:

```bash
just ci
```

## Temporal development server

Alkahest expects Temporal's local dev service on `localhost:7233` for local gateway testing. Temporal's Go SDK documentation describes installing the SDK with `go get go.temporal.io/sdk` and using `temporal server start-dev` for a local service.

The gateway endpoint is separate from Temporal Frontend. Elixir talks to the Alkahest gateway; the gateway talks to Temporal Frontend.

## License

MIT, copyright 2026 nshkrdotcom.
