defmodule Alkahest.Proto.Workflow.V1.MetadataEntry do
  @moduledoc "Metadata key/value entry carried through the Alkahest gateway contract."
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  field(:key, 1, type: :string)
  field(:value, 2, type: :string)
end

defmodule Alkahest.Proto.Workflow.V1.WorkflowRef do
  @moduledoc "Stable Temporal workflow reference returned through Alkahest DTOs."
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  field(:namespace, 1, type: :string)
  field(:workflow_id, 2, type: :string, json_name: "workflowId")
  field(:run_id, 3, type: :string, json_name: "runId")
end

defmodule Alkahest.Proto.Workflow.V1.WorkflowError do
  @moduledoc "Normalized workflow error returned by the Alkahest gateway."
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  field(:code, 1, type: :string)
  field(:message, 2, type: :string)
  field(:retryable, 3, type: :bool)
end

defmodule Alkahest.Proto.Workflow.V1.StartWorkflowRequest do
  @moduledoc "Request to start a workflow through the Alkahest gateway."
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  alias Alkahest.Proto.Workflow.V1.MetadataEntry

  field(:namespace, 1, type: :string)
  field(:workflow_id, 2, type: :string, json_name: "workflowId")
  field(:workflow_type, 3, type: :string, json_name: "workflowType")
  field(:task_queue, 4, type: :string, json_name: "taskQueue")
  field(:input_json, 5, type: :string, json_name: "inputJson")
  field(:metadata, 6, repeated: true, type: MetadataEntry)
  field(:idempotency_key, 7, type: :string, json_name: "idempotencyKey")
  field(:trace_id, 8, type: :string, json_name: "traceId")
end

defmodule Alkahest.Proto.Workflow.V1.StartWorkflowResponse do
  @moduledoc "Response from starting a workflow through the Alkahest gateway."
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  alias Alkahest.Proto.Workflow.V1.WorkflowError
  alias Alkahest.Proto.Workflow.V1.WorkflowRef

  field(:ref, 1, type: WorkflowRef)
  field(:status, 2, type: :string)
  field(:error, 3, type: WorkflowError)
end

defmodule Alkahest.Proto.Workflow.V1.SignalWorkflowRequest do
  @moduledoc "Request to send a signal to a workflow through the Alkahest gateway."
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  alias Alkahest.Proto.Workflow.V1.MetadataEntry
  alias Alkahest.Proto.Workflow.V1.WorkflowRef

  field(:ref, 1, type: WorkflowRef)
  field(:signal_name, 2, type: :string, json_name: "signalName")
  field(:payload_json, 3, type: :string, json_name: "payloadJson")
  field(:metadata, 4, repeated: true, type: MetadataEntry)
  field(:idempotency_key, 5, type: :string, json_name: "idempotencyKey")
  field(:trace_id, 6, type: :string, json_name: "traceId")
end

defmodule Alkahest.Proto.Workflow.V1.SignalWorkflowResponse do
  @moduledoc "Response from sending a workflow signal."
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  alias Alkahest.Proto.Workflow.V1.WorkflowError
  alias Alkahest.Proto.Workflow.V1.WorkflowRef

  field(:ref, 1, type: WorkflowRef)
  field(:status, 2, type: :string)
  field(:error, 3, type: WorkflowError)
end

defmodule Alkahest.Proto.Workflow.V1.QueryWorkflowRequest do
  @moduledoc "Request to query a workflow through the Alkahest gateway."
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  alias Alkahest.Proto.Workflow.V1.MetadataEntry
  alias Alkahest.Proto.Workflow.V1.WorkflowRef

  field(:ref, 1, type: WorkflowRef)
  field(:query_name, 2, type: :string, json_name: "queryName")
  field(:payload_json, 3, type: :string, json_name: "payloadJson")
  field(:metadata, 4, repeated: true, type: MetadataEntry)
  field(:trace_id, 5, type: :string, json_name: "traceId")
end

defmodule Alkahest.Proto.Workflow.V1.QueryWorkflowResponse do
  @moduledoc "Response from a workflow query."
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  alias Alkahest.Proto.Workflow.V1.WorkflowError
  alias Alkahest.Proto.Workflow.V1.WorkflowRef

  field(:ref, 1, type: WorkflowRef)
  field(:result_json, 2, type: :string, json_name: "resultJson")
  field(:error, 3, type: WorkflowError)
end

defmodule Alkahest.Proto.Workflow.V1.CancelWorkflowRequest do
  @moduledoc "Request to cancel a workflow."
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  alias Alkahest.Proto.Workflow.V1.MetadataEntry
  alias Alkahest.Proto.Workflow.V1.WorkflowRef

  field(:ref, 1, type: WorkflowRef)
  field(:reason, 2, type: :string)
  field(:metadata, 3, repeated: true, type: MetadataEntry)
  field(:trace_id, 4, type: :string, json_name: "traceId")
end

defmodule Alkahest.Proto.Workflow.V1.CancelWorkflowResponse do
  @moduledoc "Response from canceling a workflow."
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  alias Alkahest.Proto.Workflow.V1.WorkflowError
  alias Alkahest.Proto.Workflow.V1.WorkflowRef

  field(:ref, 1, type: WorkflowRef)
  field(:status, 2, type: :string)
  field(:error, 3, type: WorkflowError)
end

defmodule Alkahest.Proto.Workflow.V1.DescribeWorkflowRequest do
  @moduledoc "Request to describe a workflow."
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  alias Alkahest.Proto.Workflow.V1.WorkflowRef

  field(:ref, 1, type: WorkflowRef)
  field(:trace_id, 2, type: :string, json_name: "traceId")
end

defmodule Alkahest.Proto.Workflow.V1.DescribeWorkflowResponse do
  @moduledoc "Response from describing a workflow."
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  alias Alkahest.Proto.Workflow.V1.MetadataEntry
  alias Alkahest.Proto.Workflow.V1.WorkflowError
  alias Alkahest.Proto.Workflow.V1.WorkflowRef

  field(:ref, 1, type: WorkflowRef)
  field(:status, 2, type: :string)
  field(:task_queue, 3, type: :string, json_name: "taskQueue")
  field(:metadata, 4, repeated: true, type: MetadataEntry)
  field(:error, 5, type: WorkflowError)
end

defmodule Alkahest.Proto.Workflow.V1.FetchWorkflowHistoryRefRequest do
  @moduledoc "Request for a compact workflow history reference."
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  alias Alkahest.Proto.Workflow.V1.WorkflowRef

  field(:ref, 1, type: WorkflowRef)
  field(:trace_id, 2, type: :string, json_name: "traceId")
end

defmodule Alkahest.Proto.Workflow.V1.FetchWorkflowHistoryRefResponse do
  @moduledoc "Response containing a compact workflow history URI."
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  alias Alkahest.Proto.Workflow.V1.WorkflowError
  alias Alkahest.Proto.Workflow.V1.WorkflowRef

  field(:ref, 1, type: WorkflowRef)
  field(:history_uri, 2, type: :string, json_name: "historyUri")
  field(:error, 3, type: WorkflowError)
end
