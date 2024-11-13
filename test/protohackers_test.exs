defmodule ProtohackersTest do
  use ExUnit.Case
  doctest Protohackers

  test "something" do
    assert Protohackers.accept(4040) == :world
  end
end
