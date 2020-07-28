defmodule TMITest do
  use ExUnit.Case
  doctest TMI

  test "greets the world" do
    assert TMI.hello() == :world
  end
end
