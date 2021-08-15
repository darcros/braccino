defmodule BraccinoTest do
  use ExUnit.Case
  doctest Braccino

  test "greets the world" do
    assert Braccino.hello() == :world
  end
end
