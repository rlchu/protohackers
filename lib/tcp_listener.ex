defmodule Protoh.TcpListener do
  # https://hexdocs.pm/elixir/task-and-gen-tcp.html
  require Logger
  # use GenServer
  #
  # def start_link(default) when is_list(default) do
  #   GenServer.start_link(__MODULE__, default)
  # end
  #
  def start_link(opts) do
    pid = spawn_link(__MODULE__, :init, [opts])
    {:ok, pid}
  end

  def init(opts) do
    server = Keyword.fetch!(opts, :server)
    port = Keyword.fetch!(opts, :port)
    listen_opts = Keyword.get(opts, :listen_opts, [])
    server_opts = Keyword.get(opts, :server_opts, [])
    task_supervisor = Keyword.get(opts, :task_supervisor, [])

    listen(server, port, task_supervisor, listen_opts, server_opts)
  end

  def listen(server, port, _task_supervisor, _listen_opts, _server_opts) do
    # fix this doc
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener(crashes)
    # 5. `buffer`: 1024 * 1000 -  ?

    {:ok, listen_socket} =
      :gen_tcp.listen(port, [
        :binary,
        packet: :line,
        # packet: :raw,
        active: false,
        reuseaddr: true,
        buffer: 1024 * 1000
      ])

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

  def child_spec(opts) do
    %{
      id: {__MODULE__, opts[:server]},
      start: {__MODULE__, :start_link, [opts]}
    }
  end
end
