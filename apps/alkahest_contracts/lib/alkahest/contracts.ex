defmodule Alkahest.Contracts do
  @moduledoc "Constructors and validation helpers for Alkahest workflow-control protobuf DTOs."

  alias Alkahest.Proto.Workflow.V1.MetadataEntry
  alias Alkahest.Proto.Workflow.V1.StartWorkflowRequest
  alias Alkahest.Proto.Workflow.V1.WorkflowRef

  @type attrs :: %{optional(atom() | String.t()) => term()}

  @spec metadata(attrs()) :: [MetadataEntry.t()]
  def metadata(attrs) when is_map(attrs) do
    attrs
    |> Enum.map(fn {key, value} ->
      %MetadataEntry{key: to_string(key), value: to_string(value)}
    end)
    |> Enum.sort_by(& &1.key)
  end

  @spec workflow_ref(attrs()) :: {:ok, WorkflowRef.t()} | {:error, {:missing, atom()}}
  def workflow_ref(attrs) when is_map(attrs) do
    ref = %WorkflowRef{
      namespace: string(attrs, :namespace),
      workflow_id: string(attrs, :workflow_id),
      run_id: string(attrs, :run_id)
    }

    require_fields(ref, [:namespace, :workflow_id])
  end

  @spec start_workflow_request(attrs()) ::
          {:ok, StartWorkflowRequest.t()} | {:error, {:missing, atom()}}
  def start_workflow_request(attrs) when is_map(attrs) do
    request = %StartWorkflowRequest{
      namespace: string(attrs, :namespace),
      workflow_id: string(attrs, :workflow_id),
      workflow_type: string(attrs, :workflow_type),
      task_queue: string(attrs, :task_queue),
      input_json: string(attrs, :input_json),
      metadata: metadata(Map.get(attrs, :metadata, Map.get(attrs, "metadata", %{}))),
      idempotency_key: string(attrs, :idempotency_key),
      trace_id: string(attrs, :trace_id)
    }

    require_fields(request, [
      :namespace,
      :workflow_id,
      :workflow_type,
      :task_queue,
      :idempotency_key,
      :trace_id
    ])
  end

  defp require_fields(struct, fields) do
    case Enum.find(fields, &(Map.fetch!(struct, &1) == "")) do
      nil -> {:ok, struct}
      field -> {:error, {:missing, field}}
    end
  end

  defp string(attrs, key) do
    attrs
    |> value(key)
    |> to_string_value()
  end

  defp value(attrs, key) do
    Map.get(attrs, key, Map.get(attrs, Atom.to_string(key), ""))
  end

  defp to_string_value(nil), do: ""
  defp to_string_value(value), do: to_string(value)
end
