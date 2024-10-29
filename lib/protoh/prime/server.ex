defmodule Protoh.Prime.Server.Bak do
  require Logger

  def start(socket), do: serve(socket)
  def start(socket, _opts), do: serve(socket)

  defp serve(socket) do
    with {:ok, data} <- :gen_tcp.recv(socket, 0),
         {:ok, json_data} <- get_json(data) do
      {:ok, encoded_json_response} =
        json_data
        |> check_prime()
        |> Jason.encode()

      :gen_tcp.send(socket, encoded_json_response <> "\n")
      dbg()
      serve(socket)
    else
      _error ->
        dbg()
        # Logger.debug("#{inspect(__MODULE__)}: Client Closed (#{inspect(socket)})")
        :gen_tcp.close(socket)
    end
  end

  defp check_prime(%{"number" => number} = json_data) do
    Map.put(json_data, "isPrime", Prime.test(number))
  end

  defp get_json(data) do
    dbg()
    Jason.decode(data)
  end
end
