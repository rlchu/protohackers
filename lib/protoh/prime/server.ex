defmodule Protoh.Prime.Server do
  require Logger

  def start(socket), do: serve(socket)
  def start(socket, _opts), do: serve(socket)

  defp parse_tcp_receive({:ok, data}), do: data
  defp parse_tcp_receive({:error, error}), do: "error!"

  defp serve(socket) do
    answer =
      case :gen_tcp.recv(socket, 0) do
        {:ok, data} -> data
        _error -> "error!"
      end

    if answer == "error!" do
      Logger.debug("error!!")
      :gen_tcp.close(socket)
    else
      {:ok, resp} = build_response(Jason.decode(answer))
      {:ok, resp} = Jason.encode(resp)
      :gen_tcp.send(socket, enc_resp <> "\n")
      serve(socket)
    end
  end

  defp build_response({:ok, %{"method" => "isPrime", "number" => number}})
       when is_number(number) do
    {:ok, %{"method" => "isPrime", "prime" => Prime.test(number)}}
  end

  # defp build_response(_), do: {:error, :invalid_object}
end
