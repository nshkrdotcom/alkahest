#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GO_OUT="$ROOT/services/temporal_gateway/gen"
ELIXIR_OUT="$ROOT/apps/alkahest_contracts/lib"
ELIXIRPB_PROTO="$ROOT/priv/protos/elixirpb.proto"
PROTO="$ROOT/priv/protos/alkahest/workflow/v1/workflow_runtime.proto"
ELIXIR_PROTO_GO_PACKAGE="github.com/nshkrdotcom/alkahest/services/temporal_gateway/gen;elixirpb"

mkdir -p "$GO_OUT" "$ELIXIR_OUT"

GO_BIN="$(go env GOBIN)"
if [[ -z "$GO_BIN" ]]; then
  GO_BIN="$(go env GOPATH)/bin"
fi
export PATH="$GO_BIN:$PATH"
protoc \
  -I "$ROOT/priv/protos" \
  --go_out="$GO_OUT" \
  --go_opt=paths=source_relative \
  --go_opt=Melixirpb.proto="$ELIXIR_PROTO_GO_PACKAGE" \
  --go-grpc_out="$GO_OUT" \
  --go-grpc_opt=paths=source_relative \
  --go-grpc_opt=Melixirpb.proto="$ELIXIR_PROTO_GO_PACKAGE" \
  "$ELIXIRPB_PROTO" \
  "$PROTO"

rm -f "$ELIXIR_OUT"/alkahest/proto/workflow/v1/*.pb.ex
protoc \
  -I "$ROOT/priv/protos" \
  --elixir_out=plugins=grpc,one_file_per_module=true,include_docs=true:"$ELIXIR_OUT" \
  "$PROTO"
