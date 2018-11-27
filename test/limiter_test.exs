defmodule LimiterTest do
  use ExUnit.Case
  doctest Limiter

  test "greets the world" do
    assert Limiter.hello() == :world
  end
end
