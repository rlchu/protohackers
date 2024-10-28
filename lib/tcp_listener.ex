defmodule Protoh.TcpListener do
  # https://hexdocs.pm/elixir/task-and-gen-tcp.html
  require Logger
  use GenServer

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default)
  end

  # def start_link(opts) do
  #   pid = spawn_link(__MODULE__, :init, [opts])
  #   {:ok, pid}
  # end
  #
  #
  def init(opts) do
    server = Keyword.fetch!(opts, :server)
    port = Keyword.fetch!(opts, :port)
    listen_opts = Keyword.get(opts, :listen_opts, [])
    server_opts = Keyword.get(opts, :server_opts, [])
    task_supervisor = Keyword.get(opts, :task_supervisor, [])
    dbg(task_supervisor)

    listen(server, port, task_supervisor, listen_opts, server_opts)
  end

  def listen(server, port, _task_supervisor, _listen_opts, _server_opts) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener(crashes)

    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    Logger.debug("#{inspect(server)}: Accepting connections on port #{port}")

    accept_client(server, listen_socket)
  end

  defp accept_client(server, listen_socket) do
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    Task.Supervisor.async(Protoh.TaskSupervisor, fn ->
      server.start(client_socket)
    end)

    accept_client(server, listen_socket)
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
