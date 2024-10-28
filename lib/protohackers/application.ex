defmodule Protohackers.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # port = String.to_integer(System.get_env("PORT") || "5050")

    children = [
      {Task.Supervisor, name: Protohackers.TaskSupervisor},
      # swap to {Protohacker.TcpListener, server: Protohacker.Echo.Server, port: 3000},
      {Task, link_it(3000)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Protohackers.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp link_it(port) do
    IO.inspect("linking it to #{port}!")
    fn -> Protohackers.TcpServer.init(port) end
  end
end
