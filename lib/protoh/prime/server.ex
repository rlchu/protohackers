defmodule Protoh.Prime.Server do
  require Logger

  def start(socket), do: serve(socket)
  def start(socket, _opts), do: serve(socket)

  defp serve(socket) do
    with {:ok, data} <- :gen_tcp.recv(socket, 0),
         {:ok, input} <- Jason.decode(data),
         response <- build_response(input),
         {:ok, enc_resp} <- Jason.encode(response) do
      dbg()
      dbg(enc_resp)
      :gen_tcp.send(socket, enc_resp <> "\n")
      serve(socket)
    else
      _error ->
        :gen_tcp.close(socket)
    end
  end

  defp build_response(%{"method" => "isPrime", "number" => number})
       when is_number(number) do
    %{"method" => "isPrime", "prime" => is_prime(number)}
  end

  defp build_response(inputs) do
    {:error, :invalid_object}
  end

  defp is_prime(number) when is_float(number) do
    false
  end

  defp is_prime(number) do
    Prime.test(number)
  end
end
