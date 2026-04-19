defmodule Alkahest.Client.GRPCSupervisor do
  @moduledoc """
  Starts the gRPC client supervisor required by `GRPC.Stub.connect/2`.

  Downstream applications may still supervise `GRPC.Client.Supervisor` themselves.
  This helper makes scripts and lightweight clients work without duplicating that
  boilerplate.
  """

  @spec ensure_started() :: {:ok, pid()} | {:error, term()}
  def ensure_started do
    case Process.whereis(GRPC.Client.Supervisor) do
      nil -> GRPC.Client.Supervisor.start_link([])
      pid when is_pid(pid) -> {:ok, pid}
    end
  end
end
