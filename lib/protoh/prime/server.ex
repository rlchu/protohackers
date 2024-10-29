defmodule Protoh.Prime.Server do
  require Logger

  def start(socket), do: serve(socket)
  def start(socket, _opts), do: serve(socket)

  defp serve(socket) do
    dbg()

    data =
      case :gen_tcp.recv(socket, 0) do
        {:ok, data} -> data
        _ -> 0
      end

    {:ok, %{"method" => _method, "number" => number}} = Jason.decode(data)

    is_prime = check_prime(number)

    response = %{method: "isPrime", prime: is_prime}

    {:ok, response_data} = Jason.encode(response)
    :ok = :gen_tcp.send(socket, response_data)
    dbg()
    serve(socket)

    #   with {:ok, data} <- :gen_tcp.recv(socket, 0),
    #         json_data <- get_json(data)
    #         response_json <- check_prime(json_data)
    #        :ok <- :gen_tcp.send(socket, response_json) do
    #     serve(socket)
    #   else
    #     _error ->
    #       Logger.debug("#{inspect(__MODULE__)}: Client Closed (#{inspect(socket)})")
    #       :gen_tcp.close(socket)
    #   end
  end

  defp check_prime(number) do
    Prime.test(number)
  end
end
