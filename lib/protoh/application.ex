defmodule Protoh.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    tcp_listener_opts = %{
      port: String.to_integer(System.get_env("PORT") || "5050"),
      server: Protoh.Echo.Server
    }

    children = [
      {Task.Supervisor, name: Protoh.TaskSupervisor},
      # swap to {Protoh.TcpListener, server: Proto.Echo.Server, port: 3000},
      {Task, fn -> Protoh.TcpListener.init(tcp_listener_opts) end}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Protoh.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
