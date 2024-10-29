defmodule Protoh.Prime.Server do
  require Logger

  def start(socket), do: serve(socket)
  def start(socket, _opts), do: serve(socket)
  #
  # defp serve(socket) do
  #   dbg()
  #
  #   data =
  #     case :gen_tcp.recv(socket, 0) do
  #       {:ok, data} -> data
  #       _ -> 0
  #     end
  #
  #   {:ok, %{"method" => _method, "number" => number}} = Jason.decode(data)
  #
  #   is_prime = check_prime(number)
  #
  #   response = %{method: "isPrime", prime: is_prime}
  #
  #   {:ok, response_data} = Jason.encode(response)
  #   :ok = :gen_tcp.send(socket, response_data)
  #   dbg()
  #   serve(socket)
  # end
  #
  defp serve(socket) do
    dbg()

    with {:ok, data} <- :gen_tcp.recv(socket, 0),
         {:ok, json_data} <- get_json(data) do
      {:ok, encoded_json_response} =
        json_data
        |> check_prime()
        |> Jason.encode()

      a = :gen_tcp.send(socket, encoded_json_response)
      dbg()
      serve(socket)
    else
      error ->
        Logger.debug(error)
        # Logger.debug("#{inspect(__MODULE__)}: Client Closed (#{inspect(socket)})")
        # :gen_tcp.close(socket)
    end
  end

  defp check_prime(%{"number" => number} = json_data) do
    Map.put(json_data, "isPrime", Prime.test(number))
  end

  defp get_json(data) do
    de = Jason.decode(data)
    dbg()
  end
end
