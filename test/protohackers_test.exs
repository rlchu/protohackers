defmodule ProtohTest do
  use ExUnit.Case
  # doctest Protoh

  test "greets the world" do
    Protoh.TcpServer.init(4045)

    assert :world == :world
  end
end
