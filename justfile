set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

ci:
  mix ci

deps:
  mix deps.get

gen-proto:
  scripts/dev/gen-proto.sh

go-test:
  cd services/temporal_gateway && go test ./...

go-fmt-check:
  scripts/dev/check-go-format.sh
