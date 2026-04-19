#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/services/temporal_gateway/gen"
mkdir -p "$OUT"

GO_BIN="$(go env GOBIN)"
if [[ -z "$GO_BIN" ]]; then
  GO_BIN="$(go env GOPATH)/bin"
fi
export PATH="$GO_BIN:$PATH"
protoc \
  -I "$ROOT/priv/protos" \
  --go_out="$OUT" \
  --go_opt=paths=source_relative \
  --go-grpc_out="$OUT" \
  --go-grpc_opt=paths=source_relative \
  "$ROOT/priv/protos/alkahest/workflow/v1/workflow_runtime.proto"
