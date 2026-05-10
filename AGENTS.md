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
- Alkahest is not in the Weld consumer set. Do not add a Weld dependency, Weld
  task, or Weld Credo check as part of Phase 2 cleanup.

## Dependency Sources

- Cross-repo dependency selection belongs in
  `build_support/dependency_sources.config.exs` and is consumed through the
  canonical `build_support/dependency_sources.exs` helper.
- App packages that need self-contained package-mode dependency selection keep
  their own canonical `apps/*/build_support/dependency_sources.*` files.
- Machine-local dependency overrides belong in `.dependency_sources.local.exs`
  or the relevant `apps/*/.dependency_sources.local.exs`. Keep those files
  untracked.
- Dependency source selection must not read environment variables.

## Runtime Environment

- Runtime application code under `lib/**` and Elixir examples must not call
  direct OS environment APIs such as `System.get_env/1`,
  `System.fetch_env/1`, `System.fetch_env!/1`, `System.put_env/2`,
  `System.delete_env/1`, or `System.get_env/0`.
- Deployment environment reads belong at OTP boot boundaries such as
  `config/runtime.exs` or a `Config.Provider`. Runtime modules and examples
  should receive explicit options or materialized application config.

Development commands:

- `mix deps.get`
- `mix ci`
- `just ci`
- `scripts/dev/install-go-temporal-tools.sh`
- `scripts/dev/gen-proto.sh`

## Blitz 0.3.0 operational note

Root workspace Blitz uses published Hex `~> 0.3.0` by default; `.blitz/` is committed compact impact state after green QC. Source and `mix.exs` changes cascade through reverse workspace dependencies; docs-only changes should stay owner-local.
