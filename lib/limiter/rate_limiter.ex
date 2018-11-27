defmodule Limiter.RateLimiter do
  @moduledoc false
  use GenServer
  require Logger

  @max_per_minute 2
  @clear_after :timer.seconds(60)
  @table :rate_limiter

  # ==========
  # Client API
  # ==========

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: via_tuple())
  end

  def log(ip) do
    case Horde.Registry.lookup(Limiter.GlobalRegistry, __MODULE__) do
      :undefined ->
        {:error, :not_found}

      [{pid, _value}] ->
        node = Kernel.node(pid)
        :rpc.call(node, __MODULE__, :get_log, [ip])
    end
  end

  def get_log(ip) do
    case :ets.update_counter(@table, ip, {2, 1}, {ip, 0}) do
      count when count > @max_per_minute -> {:error, :rate_limited}
      _count -> :ok
    end
  end

  # ================
  # Server Callbacks
  # ================

  def init(_opts) do
    Logger.info("[limiter on #{inspect(Node.self())}][RateLimiter]: Initializing...")

    :ets.new(@table, [
      :set,
      :named_table,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])

    schedule_clear()
    {:ok, %{}}
  end

  def handle_info(:clear, state) do
    Logger.info("[limiter on #{inspect(Node.self())}][RateLimiter]: Clearing table...")
    :ets.delete_all_objects(@table)
    schedule_clear()
    {:noreply, state}
  end

  # =================
  # Private Functions
  # =================

  defp schedule_clear do
    Process.send_after(self(), :clear, @clear_after)
  end

  defp via_tuple do
    {:via, Horde.Registry, {Limiter.GlobalRegistry, __MODULE__}}
  end
end
