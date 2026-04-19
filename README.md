# Alkahest

<p align="center">
  <img src="assets/alkahest.svg" alt="Alkahest logo" width="200" height="200" />
</p>

Alkahest is a reusable Temporal facade substrate for durable distributed agentic systems.

It gives Elixir applications a stable workflow-control boundary without forcing the BEAM to host Temporal workers, depend on immature Elixir Temporal SDK runtime machinery, or duplicate Temporal transport glue in every application repo.

Alkahest is not an umbrella app. It is a monorepo of separate Mix projects under `apps/`, coordinated by Blitz, plus a Go gateway service under `services/`.

## Why this exists

The ecosystem needs durable execution for long-running distributed agentic workflows. Jobs can be persisted in a database, retried, chained, and monitored, but durable workflow execution is a different requirement:

- a run can last days or weeks;
- timers must survive process and node failure;
- signals must mutate live orchestration safely;
- fan-out and fan-in must be reconstructable;
- operator cancellation, pause, resume, retry, and replan must be workflow-native;
- worker loss must not lose orchestration state;
- activity retries must not require custom state-machine tables in every repo;
- workflow identity, task queues, search attributes, and run refs must become part of the platform contract.

Temporal is the right durable execution substrate for that class of problem. The friction is not Temporal itself. The friction is that the Elixir ecosystem does not currently have an official, production-battle-tested Temporal SDK equivalent to Go, Java, TypeScript, Python, or .NET.

Alkahest exists to solve that integration problem cleanly.

## Core decision

Alkahest separates three concerns that are often conflated:

| Concern | Owner | Notes |
|---|---|---|
| Product and domain orchestration intent | Mezzanine, AppKit, product repos | Uses product-safe DTOs and domain refs. |
| Reusable Temporal client facade | Alkahest | Owns Elixir facade, protobuf/gRPC contracts, gateway protocol, and test support. |
| Temporal protocol and worker runtime | Official Temporal SDKs | Go gateway and external workers use official SDKs. |

Elixir code starts, signals, queries, cancels, and describes workflows through an Elixir facade.

The facade talks to the Alkahest gateway over Alkahest-owned gRPC/protobuf.

The gateway talks to Temporal Frontend through the official Temporal Go SDK.

External workers poll Temporal task queues through official Temporal SDKs.

## What Alkahest is not

Alkahest is not a Temporal clone.

Alkahest is not an Elixir Temporal worker runtime.

Alkahest is not a replacement for Temporal's event history, matching service, timers, task queues, replay semantics, or activity retry semantics.

Alkahest is not a place for product DTOs, tenant policy, authority decisions, lower execution truth, semantic context, or AppKit public contracts.

Alkahest is not a Mezzanine-specific one-off gateway.

Alkahest is the reusable boundary between Elixir systems and Temporal's official SDK world.

## Architecture

```text
AppKit / product surface
  -> Mezzanine
    -> Mezzanine.WorkflowRuntime
      -> Alkahest.Client
        -> Alkahest gRPC gateway contract
          -> Alkahest temporal_gateway service
            -> Temporal Frontend over native gRPC/protobuf

external official-SDK workers
  -> Temporal Frontend task queues
  -> approved system APIs or repo-owned command surfaces for side effects
```

The key rule is that the Elixir application does not bind to Temporal internals.

Mezzanine should not import raw Temporal protobuf modules.

Mezzanine should not open raw Temporal gRPC connections.

Mezzanine should not define a duplicate generic Temporal gateway.

Mezzanine should not run Temporal workers inside the BEAM for Phase 4.

Mezzanine should wrap `Alkahest.Client` behind `Mezzanine.WorkflowRuntime`.

## Initial Phase 4 use

The first serious downstream consumer is Mezzanine.

Mezzanine will expose a domain boundary:

```elixir
Mezzanine.WorkflowRuntime.start_workflow(request)
Mezzanine.WorkflowRuntime.signal_workflow(request)
Mezzanine.WorkflowRuntime.query_workflow(request)
Mezzanine.WorkflowRuntime.cancel_workflow(request)
Mezzanine.WorkflowRuntime.describe_workflow(request)
Mezzanine.WorkflowRuntime.history_ref(request)
```

`Mezzanine.WorkflowRuntime` owns Mezzanine DTOs, failure classes, release-manifest fields, and product-safe return values.

`Mezzanine.WorkflowRuntime` then maps those DTOs to `Alkahest.Client`.

Alkahest owns the reusable transport shape.

The Temporal gateway owns the official SDK call.

The worker owns workflow and activity execution.

The Temporal cluster owns durable workflow state.

Postgres remains the source of application facts, audit, lower truth, semantic truth, claim checks, and projections.

## Initial dependency shape

During sibling development:

```elixir
def deps do
  [
    {:alkahest_client, path: "../alkahest/apps/alkahest_client"}
  ]
end
```

For Stack Lab unit proofs that should not require a live Temporal service:

```elixir
def deps do
  [
    {:alkahest_test_support, path: "../alkahest/apps/alkahest_test_support", only: :test}
  ]
end
```

For release-pinned usage:

```elixir
def deps do
  [
    {:alkahest_client,
     github: "nshkrdotcom/alkahest",
     ref: "PINNED_COMMIT_SHA",
     subdir: "apps/alkahest_client"}
  ]
end
```

Release manifests should record the Alkahest repository URL, Git SHA, package versions, proto checksum, gateway service version, official Temporal Go SDK version, task queues, workflow versions, activity versions, signal versions, and query versions.

## Projects

| Path | Purpose |
|---|---|
| `apps/alkahest_contracts` | Shared protobuf/gRPC contract modules, workflow DTOs, validation helpers, and error shapes. |
| `apps/alkahest_client` | Elixir client facade used by downstream Elixir systems. |
| `apps/alkahest_test_support` | Reusable fakes, fixtures, and proof support for downstream tests. |
| `services/temporal_gateway` | Go service that uses the official Temporal Go SDK to call Temporal Frontend. |
| `examples` | Runnable local live example for Temporal dev server, gateway, sample worker, and Elixir client. |

## Facade operations

Alkahest intentionally starts with a narrow workflow-control surface:

| Operation | Purpose |
|---|---|
| `start_workflow` | Start a durable workflow with explicit namespace, workflow id, workflow type, task queue, headers, search attributes, and input payload. |
| `signal_workflow` | Send an authorized mutation signal to a live workflow. |
| `query_workflow` | Query live workflow state through a safe query name and payload. |
| `cancel_workflow` | Request workflow cancellation through a durable control path. |
| `describe_workflow` | Fetch workflow execution metadata without exposing raw SDK structs. |
| `history_ref` | Return a safe reference to workflow history or visibility evidence, not a giant raw history payload by default. |

This is deliberately smaller than the full Temporal API.

The first goal is not to expose every Temporal feature. The first goal is to make the correct workflow-control path reusable, typed, observable, and stable.

## Boundary rules

Alkahest protobuf structs are transport details.

AppKit, product DTOs, operator DTOs, and public Mezzanine DTOs must not expose Alkahest protobuf structs.

Downstream Elixir repos should not import raw Temporal SDK/protobuf/gRPC modules.

Downstream Elixir repos should not call Temporal Frontend directly.

Downstream Elixir repos should not create duplicate generic Temporal gateway services.

Workers should not mutate arbitrary application database tables.

Workers should call approved system APIs or repo-owned command surfaces for side effects.

Large payloads should not enter workflow history.

Workflow history should carry compact refs, ids, hashes, status summaries, and activity outcomes.

## Why not just use an Elixir Temporal library directly

There are useful Elixir Temporal experiments and libraries, but Phase 4 needs a production-oriented architecture that can survive the current SDK gap.

The main risks in direct Elixir Temporal integration are:

- incomplete SDK coverage;
- weak compatibility guarantees against Temporal server upgrades;
- worker runtime correctness concerns;
- replay semantics that must match official SDK behavior;
- Rustler/NIF risk if a library embeds a native runtime inside the BEAM;
- duplicated adapter code across multiple repos;
- unclear operational ownership for auth, retries, deadlines, search attributes, payload codecs, and error mapping.

Alkahest avoids those risks by putting official-SDK responsibility in a small gateway and external workers while preserving an Elixir-native facade for the rest of the stack.

This is not a hedge against Temporal. It is the opposite. It is a way to use Temporal seriously without pretending the Elixir SDK ecosystem is already equivalent to Go or TypeScript.

## Why this should be a separate library

The Temporal boundary is not Mezzanine-specific.

The same workflow-control operations will matter to other Elixir systems:

- start workflow;
- signal workflow;
- query workflow;
- cancel workflow;
- describe workflow;
- map durable execution errors to stable app errors;
- attach tenant, trace, authority, and idempotency metadata;
- keep raw Temporal SDK objects out of public DTOs;
- test workflow callers without a live Temporal service.

If this lived directly in Mezzanine, it would become ad hoc product infrastructure.

By making it Alkahest, the stack gets a reusable library with its own versioning, contracts, changelog, docs, tests, gateway code, and production hardening path.

## How this relates to Mezzanine

Mezzanine is the durable workflow host for the current ecosystem.

Mezzanine owns:

- workflow type names for the product domain;
- deterministic workflow id format;
- command receipt and workflow ref persistence;
- starter outbox policy;
- signal/query/cancel DTOs;
- activity boundary by repo;
- release manifest fields;
- operator incident reconstruction;
- Stack Lab proof obligations.

Alkahest owns:

- reusable Elixir client facade;
- reusable protobuf/gRPC transport;
- gateway request/response contracts;
- gateway error mapping shape;
- Go gateway skeleton;
- reusable test support.

Temporal owns:

- workflow history;
- timers;
- task queues;
- matching;
- activity retry;
- worker polling;
- workflow execution durability;
- visibility and server-side workflow metadata.

## Development setup

Install Elixir dependencies:

```bash
mix deps.get
```

Install Go Temporal tooling and protobuf generators:

```bash
scripts/dev/install-go-temporal-tools.sh
```

Regenerate Go and Elixir protobuf/gRPC bindings:

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

Alkahest expects Temporal's local dev service on `localhost:7233` for local gateway testing.

The gateway endpoint is separate from Temporal Frontend.

Elixir talks to the Alkahest gateway.

The Alkahest gateway talks to Temporal Frontend.

External workers poll Temporal Frontend task queues.

For local development the stack should look like this:

```text
Mezzanine on dev machine
  -> local Alkahest gateway
    -> localhost:7233 Temporal dev server

local external worker
  -> localhost:7233 Temporal dev server
  -> local system APIs
```

The local Temporal service is development infrastructure only. It is not the production topology.

## Live example

Run the complete local path with one command:

```bash
examples/run_all.sh
```

The runner reuses an existing Temporal dev server on `127.0.0.1:7233` or starts one with `temporal server start-dev`. It then starts or reuses the Alkahest gateway on `127.0.0.1:9090`, starts the sample Go worker on task queue `alkahest.dev`, and runs `examples/elixir_client_smoke.exs`.

The smoke proves:

```text
Elixir Alkahest.Client
  -> Alkahest gRPC gateway
  -> official Temporal Go SDK
  -> Temporal dev server
  -> official-SDK sample worker
```

Expected final output includes:

```text
[alkahest-example] workflow status Completed
[alkahest-example] history ref temporal://default/...
[alkahest-example] OK
Alkahest live example completed successfully.
```

See `examples/README.md` for environment variables and troubleshooting.

## Elixir gRPC supervisor

The `grpc` Elixir library requires `GRPC.Client.Supervisor` before client connections are opened.

`Alkahest.Client` now starts it idempotently before gRPC calls, so scripts and examples work without manual boilerplate.

Downstream OTP applications may still supervise it explicitly:

```elixir
children = [
  {GRPC.Client.Supervisor, []}
]
```

Keeping it in the application supervision tree is appropriate when the downstream service wants explicit lifecycle ownership.

## Protobuf generation

The shared contract source is `priv/protos/alkahest/workflow/v1/workflow_runtime.proto`.

`scripts/dev/gen-proto.sh` regenerates:

- Go protobuf and gRPC bindings under `services/temporal_gateway/gen`;
- Elixir protobuf and gRPC modules under `apps/alkahest_contracts/lib`.

The proto imports `priv/protos/elixirpb.proto` so generated Elixir modules keep the public `Alkahest.Proto.Workflow.V1` namespace while the Go bindings keep their gateway import path.

## Gateway service

The gateway is intentionally small.

It should expose stable internal RPCs for workflow control and hide official SDK details.

Expected gateway responsibilities:

- create and hold Temporal SDK client configuration;
- connect to Temporal Frontend;
- apply namespace and task queue policy;
- start workflows;
- signal workflows;
- query workflows;
- cancel workflows;
- describe workflows;
- return history references;
- map Temporal SDK errors into stable Alkahest error classes;
- propagate trace, tenant, authority, idempotency, and request metadata;
- enforce deadlines and retry posture for client calls;
- emit logs, metrics, and traces.

Expected gateway non-responsibilities:

- it should not own product authorization;
- it should not own Mezzanine command receipts;
- it should not own workflow business logic;
- it should not own activity side effects;
- it should not expose raw Temporal SDK structs to Elixir callers;
- it should not mutate arbitrary app databases.

## Worker runtime

Phase 4 workflow and activity execution should run in external official-SDK workers.

Workers poll Temporal task queues.

Workers execute workflow code and activity code.

Activities call approved system APIs or repo-owned command surfaces.

Activities return compact refs and status summaries.

Activities should be idempotent.

Workers should not make public DTOs depend on worker implementation language.

Workers should not expose Alkahest protobuf structs or Temporal SDK structs to AppKit or product surfaces.

## Testing model

Alkahest has two testing roles.

First, Alkahest must test its own contracts, client facade, generated modules, and gateway integration boundaries.

Second, Alkahest provides `alkahest_test_support` so downstream repos can unit-test workflow callers without requiring a live Temporal service for every proof.

Downstream tests should distinguish:

| Proof type | Expected substrate |
|---|---|
| Unit proof for Mezzanine DTO mapping | `alkahest_test_support` fake adapter. |
| Contract proof for Alkahest client request shape | Alkahest fixtures and validation. |
| Distributed proof for workflow start/signal/query | Alkahest gateway plus live Temporal dev server. |
| Worker-loss and timer proof | Temporal dev server plus external official-SDK worker. |
| Release proof | Manifest evidence, source scans, task queue registrations, gateway version, worker version. |

## Production direction

The long-term production target is not a local dev server and a manually started gateway.

The long-term production target is:

```text
Elixir services
  -> Alkahest gateway service over internal gRPC
    -> Temporal Cloud or HA self-hosted Temporal Frontend

external worker deployments
  -> Temporal Cloud or HA self-hosted Temporal Frontend
  -> approved internal system APIs
```

Production hardening should add:

- TLS or mTLS between Elixir services and Alkahest gateway;
- Temporal Cloud API key or mTLS support where applicable;
- namespace configuration;
- task queue naming policy;
- workflow id reuse policy;
- payload codec policy;
- search attribute registry;
- header propagation;
- deadline and retry policy;
- structured error taxonomy;
- metrics;
- distributed tracing;
- audit logging;
- compatibility tests against supported Temporal server versions;
- release manifest emission;
- gateway rolling deploy policy;
- worker rolling deploy policy;
- workflow versioning policy;
- disaster recovery notes for Temporal persistence and visibility.

## Production topology options

| Mode | Use case |
|---|---|
| Local dev server | Individual development and smoke testing. |
| Shared dev Temporal cluster | Multi-dev integration and Stack Lab distributed proofs. |
| Temporal Cloud | Preferred managed production option when operational burden should stay low. |
| HA self-hosted Temporal | Production option when infrastructure ownership, locality, or compliance requires it. |

Temporal production is not just one local binary.

A real production deployment has Temporal Frontend, History, Matching, Worker services, persistence, visibility, auth, metrics, logs, backups, retention policy, and upgrade policy.

Alkahest should keep Elixir applications insulated from those operational details while still exposing enough metadata for observability, release manifests, and incident reconstruction.

## Long-term evolution

Alkahest can grow in several directions without changing its core boundary.

Near term:

- stabilize request and response DTOs;
- harden error mapping;
- add richer test fixtures;
- make gateway startup and local dev scripts easier;
- add gateway health checks;
- add gateway metrics;
- add release manifest helpers.

Medium term:

- add payload codec hooks;
- add auth and mTLS support;
- add search attribute helpers;
- add workflow version metadata helpers;
- add task queue registry helpers;
- add stronger generated docs for gRPC contracts;
- add compatibility tests against supported Temporal server versions.

Long term:

- publish Hex packages for the Elixir apps;
- publish versioned gateway containers;
- support multiple gateway implementations if justified;
- adopt or wrap a mature official-quality Elixir Temporal SDK if one emerges;
- contribute useful protocol/client pieces upstream where appropriate;
- keep the public facade stable even if the internal gateway changes.

The desired mature state is not permanent indirection for its own sake. The desired mature state is a stable Elixir workflow-control library whose internals can evolve as the Temporal and Elixir ecosystems mature.

## Compatibility stance

Alkahest should maintain stable public contracts once released.

Phase 4 downstream integration, however, is a big-bang cutover. It does not preserve old Oban workflow paths, compatibility shims, or dual-run orchestration.

For Alkahest itself, compatibility means:

- versioned protobuf/gRPC contracts;
- explicit changelog entries;
- migration notes for downstream callers;
- generated fixture updates;
- release manifest fields;
- no accidental exposure of raw Temporal SDK structs through Elixir public APIs.

## Repository commands

Fetch dependencies:

```bash
mix deps.get
```

Run Blitz CI across Mix projects:

```bash
mix ci
```

Run with `just`:

```bash
just ci
```

Generate protobuf bindings:

```bash
scripts/dev/gen-proto.sh
```

Install Go Temporal tooling:

```bash
scripts/dev/install-go-temporal-tools.sh
```

## Status

Alkahest is currently the Phase 4 Temporal substrate for the nshkrdotcom ecosystem.

The immediate downstream target is Mezzanine.

The immediate proof target is Stack Lab.

The immediate runtime target is local Temporal development plus Alkahest gateway plus external official-SDK workers.

The long-term runtime target is Temporal Cloud or HA self-hosted Temporal with Alkahest gateway and external workers deployed as normal services.

## License

MIT, copyright 2026 nshkrdotcom.
