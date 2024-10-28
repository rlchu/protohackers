defmodule ProtohackersTest do
  use ExUnit.Case
  doctest Protohackers

  @skip
  test "greets the world" do
    thing = Protohackers.accept(4044)
    dbg(thing)
    assert Protohackers.accept(4044) == :world
  end
end
