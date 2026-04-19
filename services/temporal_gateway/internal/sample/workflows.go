package sample

import (
	"context"
	"time"

	"go.temporal.io/sdk/workflow"
)

// ExecutionLifecycleWorkflow is a minimal sample workflow registered by the development worker.
func ExecutionLifecycleWorkflow(ctx workflow.Context, inputJSON string) (string, error) {
	activityOptions := workflow.ActivityOptions{StartToCloseTimeout: 10 * time.Second}
	ctx = workflow.WithActivityOptions(ctx, activityOptions)

	var result string
	if err := workflow.ExecuteActivity(ctx, RecordExecutionLifecycle, inputJSON).Get(ctx, &result); err != nil {
		return "", err
	}

	return result, nil
}

// RecordExecutionLifecycle is a sample activity. Real workers call approved system APIs instead.
func RecordExecutionLifecycle(_ context.Context, inputJSON string) (string, error) {
	return inputJSON, nil
}
