package gateway

import (
	"context"
	"fmt"

	workflowv1 "github.com/nshkrdotcom/alkahest/services/temporal_gateway/gen/alkahest/workflow/v1"
	enums "go.temporal.io/api/enums/v1"
	"go.temporal.io/sdk/client"
)

// Service implements the Alkahest gRPC gateway contract over the official Temporal Go SDK.
type Service struct {
	workflowv1.UnimplementedWorkflowRuntimeGatewayServer
	client    client.Client
	namespace string
}

// NewService builds a gateway service backed by a Temporal client.
func NewService(temporalClient client.Client, namespace string) *Service {
	return &Service{client: temporalClient, namespace: namespace}
}

// StartWorkflow starts a workflow execution through Temporal.
func (s *Service) StartWorkflow(ctx context.Context, req *workflowv1.StartWorkflowRequest) (*workflowv1.StartWorkflowResponse, error) {
	workflowRun, err := s.client.ExecuteWorkflow(
		ctx,
		client.StartWorkflowOptions{
			ID:                    req.GetWorkflowId(),
			TaskQueue:             req.GetTaskQueue(),
			WorkflowIDReusePolicy: enums.WORKFLOW_ID_REUSE_POLICY_REJECT_DUPLICATE,
		},
		req.GetWorkflowType(),
		req.GetInputJson(),
	)
	if err != nil {
		return &workflowv1.StartWorkflowResponse{Error: normalizeError(err)}, nil
	}

	return &workflowv1.StartWorkflowResponse{
		Ref: &workflowv1.WorkflowRef{
			Namespace:  s.namespace,
			WorkflowId: workflowRun.GetID(),
			RunId:      workflowRun.GetRunID(),
		},
		Status: "started",
	}, nil
}

// SignalWorkflow sends a signal to a workflow execution.
func (s *Service) SignalWorkflow(ctx context.Context, req *workflowv1.SignalWorkflowRequest) (*workflowv1.SignalWorkflowResponse, error) {
	ref := req.GetRef()
	if err := s.client.SignalWorkflow(ctx, ref.GetWorkflowId(), ref.GetRunId(), req.GetSignalName(), req.GetPayloadJson()); err != nil {
		return &workflowv1.SignalWorkflowResponse{Ref: ref, Error: normalizeError(err)}, nil
	}

	return &workflowv1.SignalWorkflowResponse{Ref: ref, Status: "signaled"}, nil
}

// QueryWorkflow queries a workflow execution.
func (s *Service) QueryWorkflow(ctx context.Context, req *workflowv1.QueryWorkflowRequest) (*workflowv1.QueryWorkflowResponse, error) {
	ref := req.GetRef()
	value, err := s.client.QueryWorkflow(ctx, ref.GetWorkflowId(), ref.GetRunId(), req.GetQueryName(), req.GetPayloadJson())
	if err != nil {
		return &workflowv1.QueryWorkflowResponse{Ref: ref, Error: normalizeError(err)}, nil
	}

	var result string
	if err := value.Get(&result); err != nil {
		return &workflowv1.QueryWorkflowResponse{Ref: ref, Error: normalizeError(err)}, nil
	}

	return &workflowv1.QueryWorkflowResponse{Ref: ref, ResultJson: result}, nil
}

// CancelWorkflow requests workflow cancellation.
func (s *Service) CancelWorkflow(ctx context.Context, req *workflowv1.CancelWorkflowRequest) (*workflowv1.CancelWorkflowResponse, error) {
	ref := req.GetRef()
	if err := s.client.CancelWorkflow(ctx, ref.GetWorkflowId(), ref.GetRunId()); err != nil {
		return &workflowv1.CancelWorkflowResponse{Ref: ref, Error: normalizeError(err)}, nil
	}

	return &workflowv1.CancelWorkflowResponse{Ref: ref, Status: "cancel_requested"}, nil
}

// DescribeWorkflow returns a compact workflow description.
func (s *Service) DescribeWorkflow(ctx context.Context, req *workflowv1.DescribeWorkflowRequest) (*workflowv1.DescribeWorkflowResponse, error) {
	ref := req.GetRef()
	description, err := s.client.DescribeWorkflowExecution(ctx, ref.GetWorkflowId(), ref.GetRunId())
	if err != nil {
		return &workflowv1.DescribeWorkflowResponse{Ref: ref, Error: normalizeError(err)}, nil
	}

	status := "unknown"
	if description.GetWorkflowExecutionInfo() != nil {
		status = description.GetWorkflowExecutionInfo().GetStatus().String()
	}

	return &workflowv1.DescribeWorkflowResponse{Ref: ref, Status: status}, nil
}

// FetchWorkflowHistoryRef returns a compact history URI rather than raw history events.
func (s *Service) FetchWorkflowHistoryRef(_ context.Context, req *workflowv1.FetchWorkflowHistoryRefRequest) (*workflowv1.FetchWorkflowHistoryRefResponse, error) {
	ref := req.GetRef()
	return &workflowv1.FetchWorkflowHistoryRefResponse{
		Ref:        ref,
		HistoryUri: fmt.Sprintf("temporal://%s/%s/%s", ref.GetNamespace(), ref.GetWorkflowId(), ref.GetRunId()),
	}, nil
}

func normalizeError(err error) *workflowv1.WorkflowError {
	return &workflowv1.WorkflowError{Code: "temporal_error", Message: err.Error(), Retryable: true}
}
