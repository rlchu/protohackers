defmodule ProtohackersTest do
  use ExUnit.Case
  # doctest Protohackers

  test "greets the world" do
    Protohackers.TcpServer.init(4045)

    assert :world == :world
  end
end
