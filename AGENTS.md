# Alkahest Agent Instructions

Alkahest is a reusable Temporal facade substrate. Do not treat it as Mezzanine-only glue.

Rules:

- Keep Elixir packages as separate Mix projects under `apps/`; this is not an umbrella app.
- Use Blitz from the root for workspace checks.
- Use gRPC/protobuf for the Alkahest gateway contract.
- Do not add raw Temporal SDK, Temporal protobuf, or direct Temporal gRPC dependencies to Elixir consumers outside the facade packages.
- Do not run Temporal workers inside Elixir in the default design.
- Keep official Temporal SDK usage in `services/temporal_gateway` and external worker services.
- Workers must call approved system APIs or repo-owned command surfaces for side effects, not arbitrary application tables.
- Run `mix ci` before committing Elixir changes.
- Run `scripts/dev/check-go-format.sh` and `go test ./...` in `services/temporal_gateway` before gateway changes.

Development commands:

- `mix deps.get`
- `mix ci`
- `just ci`
- `scripts/dev/install-go-temporal-tools.sh`
- `scripts/dev/gen-proto.sh`
