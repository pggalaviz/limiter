defmodule Limiter.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    Limiter.Supervisor.start_link([])
  end
end
