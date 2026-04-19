# Getting Started

1. Install Elixir, Go, `protoc`, and the Temporal CLI.
2. Run `mix deps.get` from the repository root.
3. Run `scripts/dev/install-go-temporal-tools.sh`.
4. Run `scripts/dev/gen-proto.sh` when the gateway proto changes.
5. Run `mix ci` before committing.

Alkahest's default integration mode is an official-SDK gateway plus external official-SDK workers. Elixir consumers use `Alkahest.Client`; they do not host Temporal workers.
