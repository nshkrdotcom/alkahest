package main

import (
	"log"
	"net"
	"os"

	workflowv1 "github.com/nshkrdotcom/alkahest/services/temporal_gateway/gen/alkahest/workflow/v1"
	"github.com/nshkrdotcom/alkahest/services/temporal_gateway/internal/gateway"
	"go.temporal.io/sdk/client"
	"google.golang.org/grpc"
)

func main() {
	listenAddr := env("ALKAHEST_GATEWAY_LISTEN", ":9090")
	temporalAddr := env("TEMPORAL_ADDRESS", client.DefaultHostPort)
	namespace := env("TEMPORAL_NAMESPACE", "default")

	temporalClient, err := client.Dial(client.Options{HostPort: temporalAddr, Namespace: namespace})
	if err != nil {
		log.Fatalf("create Temporal client: %v", err)
	}
	defer temporalClient.Close()

	listener, err := net.Listen("tcp", listenAddr)
	if err != nil {
		log.Fatalf("listen on %s: %v", listenAddr, err)
	}

	server := grpc.NewServer()
	workflowv1.RegisterWorkflowRuntimeGatewayServer(server, gateway.NewService(temporalClient, namespace))

	log.Printf("Alkahest Temporal gateway listening on %s and using Temporal %s namespace %s", listenAddr, temporalAddr, namespace)
	if err := server.Serve(listener); err != nil {
		log.Fatalf("serve gateway: %v", err)
	}
}

func env(name string, fallback string) string {
	value := os.Getenv(name)
	if value == "" {
		return fallback
	}

	return value
}
