defmodule Protoh.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      {Task.Supervisor, name: Protoh.TaskSupervisor},
      # {Protoh.TcpListener, server: Protohacker.Echo.Server, port: 3000},
      {Task, fn -> Protoh.accept(port) end}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Protoh.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
