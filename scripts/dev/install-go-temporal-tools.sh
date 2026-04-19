#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

command -v go >/dev/null || { echo "go is required" >&2; exit 1; }
command -v protoc >/dev/null || { echo "protoc is required" >&2; exit 1; }

go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

(
  cd "$ROOT/services/temporal_gateway"
  go mod download
)

if ! command -v temporal >/dev/null; then
  cat >&2 <<'MSG'
Temporal CLI is not on PATH. Install it using Temporal's official instructions, then run:

  temporal server start-dev

Local Temporal Frontend defaults to localhost:7233 and Web UI to http://localhost:8233.
MSG
fi
