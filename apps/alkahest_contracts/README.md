# Alkahest Contracts

Typed protobuf/gRPC contracts and validation helpers for the reusable Alkahest workflow-control facade.

The source contract is `priv/protos/alkahest/workflow/v1/workflow_runtime.proto`.

Regenerate both Go and Elixir bindings from the repository root:

```bash
scripts/dev/gen-proto.sh
```

Generated Elixir modules live under `lib/alkahest/proto/workflow/v1` and keep the public namespace `Alkahest.Proto.Workflow.V1`.
