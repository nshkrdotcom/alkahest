defmodule Alkahest.Client.GRPCSupervisorTest do
  use ExUnit.Case, async: false

  alias Alkahest.Client.GRPCSupervisor

  setup do
    stop_grpc_supervisor()

    on_exit(fn ->
      stop_grpc_supervisor()
    end)
  end

  test "ensure_started starts the grpc client supervisor when it is absent" do
    refute Process.whereis(GRPC.Client.Supervisor)

    assert {:ok, pid} = GRPCSupervisor.ensure_started()
    assert Process.alive?(pid)
    assert Process.whereis(GRPC.Client.Supervisor) == pid
  end

  test "ensure_started is idempotent when the grpc client supervisor is already running" do
    assert {:ok, pid} = GRPC.Client.Supervisor.start_link([])

    assert {:ok, ^pid} = GRPCSupervisor.ensure_started()
    assert Process.whereis(GRPC.Client.Supervisor) == pid
  end

  defp stop_grpc_supervisor do
    case Process.whereis(GRPC.Client.Supervisor) do
      nil ->
        :ok

      pid ->
        try do
          DynamicSupervisor.stop(pid)
        catch
          :exit, _reason -> :ok
        end
    end
  end
end
