defmodule Limiter.HordeConnector do
  @moduledoc false
  require Logger

  def connect() do
    Node.list()
    |> Enum.each(fn node ->
      Logger.debug(fn ->
        "[limiter on #{inspect(Node.self())}]: Connecting Horde to #{inspect(node)}"
      end)

      Horde.Cluster.join_hordes(Limiter.GlobalRegistry, {Limiter.GlobalRegistry, node})
      Horde.Cluster.join_hordes(Limiter.GlobalSupervisor, {Limiter.GlobalSupervisor, node})
    end)
  end

  def start_children() do
    Horde.Supervisor.start_child(Limiter.GlobalSupervisor, Limiter.RateLimiter)
  end
end
