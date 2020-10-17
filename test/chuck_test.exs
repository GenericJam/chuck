defmodule ChuckTest do
  use ExUnit.Case
  doctest Chuck

  test "greets the world" do
    assert Chuck.hello() == :world
  end
end
