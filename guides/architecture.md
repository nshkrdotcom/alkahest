# Architecture

Alkahest separates application workflow intent from Temporal SDK mechanics.

- `alkahest_contracts` owns typed workflow-control contracts.
- `alkahest_client` owns the Elixir facade and gRPC client adapter.
- `temporal_gateway` owns official Temporal SDK calls.
- external workers own task queue polling and activity execution.

This split lets downstream systems replace the gateway implementation later without changing product contracts.
