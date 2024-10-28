defmodule Protohackers do
  # taken basically straight from:
  # https://hexdocs.pm/elixir/task-and-gen-tcp.html
  require Logger

  def accept(port) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener(crashes)

    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    {:ok, pid} =
      Task.Supervisor.start_child(Protohackers.TaskSupervisor, fn ->
        serve(client)
      end)

    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end

  # ** (ArgumentError) The module Protohackers was given as a child to a supervisor
  #    but it does not implement child_spec/1.
  #
  #    If you own the given module, please define a child_spec/1 function
  #    that receives an argument and returns a child specification as a map.
  #    For example:
  #
  #        def child_spec(opts) do
  #          %{
  #            id: __MODULE__,
  #            start: {__MODULE__, :start_link, [opts]},
  #            type: :worker,
  #            restart: :permanent,
  #            shutdown: 500
  #          }
  #        end
  #

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end
end
