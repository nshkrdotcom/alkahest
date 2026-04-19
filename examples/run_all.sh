#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${ALKAHEST_EXAMPLE_LOG_DIR:-$(mktemp -d "${TMPDIR:-/tmp}/alkahest-example.XXXXXX")}"

TEMPORAL_ADDRESS="${TEMPORAL_ADDRESS:-127.0.0.1:7233}"
TEMPORAL_NAMESPACE="${TEMPORAL_NAMESPACE:-default}"
TEMPORAL_UI_PORT="${TEMPORAL_UI_PORT:-8233}"
ALKAHEST_GATEWAY_ENDPOINT="${ALKAHEST_GATEWAY_ENDPOINT:-127.0.0.1:9090}"
ALKAHEST_TASK_QUEUE="${ALKAHEST_TASK_QUEUE:-alkahest.dev}"

STARTED_PIDS=()

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 1
  fi
}

split_host_port() {
  local address="$1"
  local host="${address%:*}"
  local port="${address##*:}"

  if [[ -z "$host" || -z "$port" || "$host" == "$port" ]]; then
    echo "Expected host:port address, got: $address" >&2
    exit 1
  fi

  printf '%s %s\n' "$host" "$port"
}

port_open() {
  local host="$1"
  local port="$2"

  timeout 1 bash -c "</dev/tcp/${host}/${port}" >/dev/null 2>&1
}

wait_for_port() {
  local name="$1"
  local host="$2"
  local port="$3"
  local log_file="$4"

  for _ in $(seq 1 60); do
    if port_open "$host" "$port"; then
      return 0
    fi

    sleep 1
  done

  echo "Timed out waiting for $name on ${host}:${port}" >&2
  echo "--- $name log: $log_file ---" >&2
  tail -n 120 "$log_file" >&2 || true
  exit 1
}

wait_for_log() {
  local name="$1"
  local pattern="$2"
  local log_file="$3"

  for _ in $(seq 1 60); do
    if grep -q "$pattern" "$log_file" 2>/dev/null; then
      return 0
    fi

    sleep 1
  done

  echo "Timed out waiting for $name log pattern: $pattern" >&2
  echo "--- $name log: $log_file ---" >&2
  tail -n 120 "$log_file" >&2 || true
  exit 1
}

start_background() {
  local name="$1"
  local log_file="$2"
  shift 2

  echo "Starting $name; log: $log_file"
  "$@" >"$log_file" 2>&1 &
  STARTED_PIDS+=("$!")
}

cleanup() {
  local pid

  for pid in "${STARTED_PIDS[@]}"; do
    if kill -0 "$pid" >/dev/null 2>&1; then
      kill "$pid" >/dev/null 2>&1 || true
    fi
  done

  for pid in "${STARTED_PIDS[@]}"; do
    wait "$pid" >/dev/null 2>&1 || true
  done
}

trap cleanup EXIT

require_command go
require_command mix
require_command temporal
require_command timeout

mkdir -p "$LOG_DIR"
echo "Using logs in $LOG_DIR"

read -r temporal_host temporal_port < <(split_host_port "$TEMPORAL_ADDRESS")
read -r gateway_host gateway_port < <(split_host_port "$ALKAHEST_GATEWAY_ENDPOINT")

if port_open "$temporal_host" "$temporal_port"; then
  echo "Using existing Temporal dev server at $TEMPORAL_ADDRESS"
else
  temporal_log="$LOG_DIR/temporal.log"
  start_background \
    "Temporal dev server" \
    "$temporal_log" \
    temporal server start-dev --ip "$temporal_host" --port "$temporal_port" --ui-port "$TEMPORAL_UI_PORT"

  wait_for_port "Temporal dev server" "$temporal_host" "$temporal_port" "$temporal_log"
fi

if port_open "$gateway_host" "$gateway_port"; then
  echo "Using existing Alkahest gateway at $ALKAHEST_GATEWAY_ENDPOINT"
else
  gateway_log="$LOG_DIR/gateway.log"
  start_background \
    "Alkahest gateway" \
    "$gateway_log" \
    bash -c \
      'cd "$1" && exec env TEMPORAL_ADDRESS="$2" TEMPORAL_NAMESPACE="$3" ALKAHEST_GATEWAY_LISTEN="$4" go run ./cmd/alkahest-temporal-gateway' \
      bash \
      "$ROOT/services/temporal_gateway" \
      "$TEMPORAL_ADDRESS" \
      "$TEMPORAL_NAMESPACE" \
      "$ALKAHEST_GATEWAY_ENDPOINT"

  wait_for_port "Alkahest gateway" "$gateway_host" "$gateway_port" "$gateway_log"
fi

worker_log="$LOG_DIR/worker.log"
start_background \
  "Alkahest sample worker" \
  "$worker_log" \
  bash -c \
    'cd "$1" && exec env TEMPORAL_ADDRESS="$2" TEMPORAL_NAMESPACE="$3" ALKAHEST_TASK_QUEUE="$4" go run ./cmd/alkahest-temporal-worker' \
    bash \
    "$ROOT/services/temporal_gateway" \
    "$TEMPORAL_ADDRESS" \
    "$TEMPORAL_NAMESPACE" \
    "$ALKAHEST_TASK_QUEUE"
wait_for_log "Alkahest sample worker" "Started Worker" "$worker_log"

(
  cd "$ROOT"
  env TEMPORAL_NAMESPACE="$TEMPORAL_NAMESPACE" \
    ALKAHEST_GATEWAY_ENDPOINT="$ALKAHEST_GATEWAY_ENDPOINT" \
    ALKAHEST_TASK_QUEUE="$ALKAHEST_TASK_QUEUE" \
    mix run examples/elixir_client_smoke.exs
)

echo "Alkahest live example completed successfully."
