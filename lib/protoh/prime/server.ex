defmodule Protoh.Prime.Server do
  require Logger

  def start(socket), do: serve(socket)
  def start(socket, _opts), do: serve(socket)

  defp serve(socket) do
    answer =
      case :gen_tcp.recv(socket, 0) do
        {:ok, data} -> data
        _error -> "error!"
      end

    if answer == "error!" do
      :gen_tcp.close(socket)
    else
      try do
        {:ok, resp} = build_response(Jason.decode(answer))
        {:ok, enc_resp} = Jason.encode(resp)
        :gen_tcp.send(socket, enc_resp <> "\n")
      rescue
        _ -> :gen_tcp.send(socket, "\n")
      end

      dbg()
      serve(socket)
    end
  end

  defp build_response({:ok, %{"method" => "isPrime", "number" => number}})
       when is_number(number) do
    {:ok, %{"method" => "isPrime", "prime" => Prime.test(number)}}
  end

  defp build_response(_), do: {:error, :invalid_object}
end
