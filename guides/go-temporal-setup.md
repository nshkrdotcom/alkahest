# Go Temporal Setup

The gateway uses the official Temporal Go SDK.

```bash
cd services/temporal_gateway
go mod download
go test ./...
```

For local Temporal service:

```bash
temporal server start-dev
```

The local Temporal Frontend listens on `localhost:7233`; the Web UI is normally `http://localhost:8233`.
