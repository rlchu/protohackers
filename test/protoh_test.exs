defmodule ProtohTest do
  use ExUnit.Case
  doctest Protoh

  test "greets the world" do
    assert Protoh.hello() == :world
  end
end
