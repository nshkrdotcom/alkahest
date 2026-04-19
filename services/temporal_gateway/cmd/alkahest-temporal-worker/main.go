package main

import (
	"log"
	"os"

	"github.com/nshkrdotcom/alkahest/services/temporal_gateway/internal/sample"
	"go.temporal.io/sdk/client"
	"go.temporal.io/sdk/worker"
)

func main() {
	temporalAddr := env("TEMPORAL_ADDRESS", client.DefaultHostPort)
	namespace := env("TEMPORAL_NAMESPACE", "default")
	taskQueue := env("ALKAHEST_TASK_QUEUE", "alkahest.dev")

	temporalClient, err := client.Dial(client.Options{HostPort: temporalAddr, Namespace: namespace})
	if err != nil {
		log.Fatalf("create Temporal client: %v", err)
	}
	defer temporalClient.Close()

	workerRuntime := worker.New(temporalClient, taskQueue, worker.Options{})
	workerRuntime.RegisterWorkflow(sample.ExecutionLifecycleWorkflow)
	workerRuntime.RegisterActivity(sample.RecordExecutionLifecycle)

	log.Printf("Alkahest Temporal worker polling %s namespace %s", taskQueue, namespace)
	if err := workerRuntime.Run(worker.InterruptCh()); err != nil {
		log.Fatalf("run worker: %v", err)
	}
}

func env(name string, fallback string) string {
	value := os.Getenv(name)
	if value == "" {
		return fallback
	}

	return value
}
