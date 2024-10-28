defmodule Protoh.Echo.Server do
  require Logger

  def start(socket, _opts), do: serve(socket)

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
end

# defmodule Protoh.Echo.Server do
#   require Logger
#
#   def start(socket, _opts), do: serve(socket)
#
#   defp serve(socket) do
#     with {:ok, data} <- :gen_tcp.recv(socket, 0),
#          :ok <- :gen_tcp.send(socket, data) do
#       serve(socket)
#     else
#       _error ->
#         Logger.debug("#{inspect(__MODULE__)}: Client Closed (#{inspect(socket)})")
#         :gen_tcp.close(socket)
#     end
#   end
# end
