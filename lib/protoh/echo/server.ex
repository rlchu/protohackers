defmodule Protoh.Echo.Server do
  require Logger

  def start(socket), do: serve(socket)
  def start(socket, _opts), do: serve(socket)

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> data
      _ -> close(socket)
    end
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end

  defp close(socket) do
    Logger.debug("#{inspect(__MODULE__)}: Client Closed (#{inspect(socket)})")
    :gen_tcp.close(socket)
  end
end
