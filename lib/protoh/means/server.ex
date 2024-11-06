defmodule Protoh.Means.Server do
  require Logger

  def start(socket), do: serve(socket)
  def start(socket, _opts), do: serve(socket)

  @message_size 9
  defp serve(socket) do
    with {:ok, data} <- :gen_tcp.recv(socket, @message_size),
         :ok <- :gen_tcp.send(socket, data) do
      IO.inspect(data)
      serve(socket)
    else
      _error ->
        Logger.debug("#{inspect(__MODULE__)}: Client Closed (#{inspect(socket)})")
        :gen_tcp.close(socket)
    end
  end
end

# # <<head::binary-size(2), rest::binary>>
# byte_size(<<81, 0, 0, 48, 0, 0, 0, 64, 0>>)
#
# <<head::binary-size(1), more::binary-size(4), more2::binary-size(4)>> =
#   <<81, 0, 0, 48, 0, 0, 0, 64, 0>>
#
# #
# defp examine_incoming(<<"I", timestamp::int32(), price::int32()>>, table) do
#   :ets.insert(table, {timestamp, price})
#
#   {:insert, :ok}
# end
#
# defp examine_incoming(<<"Q", min_time::int32(), max_time::int32()>>, table) do
# end
