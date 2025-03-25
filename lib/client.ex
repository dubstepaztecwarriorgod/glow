defmodule GlowClient do
  defstruct [:username, :address, :port, :socket]

  def start do
    client = login()
    IO.inspect(client)

    case :gen_tcp.connect(client.address, client.port, [:binary, active: false]) do
      {:ok, socket} ->
        IO.puts("Sucess! Connected to #{client.address}:#{client.port} as #{client.username}")
        client = %GlowClient{client | socket: socket}
        spawn(fn -> listen(client) end)
        handle_message(client)

      {:error, reason} ->
        exit(reason)
    end
  end

  defp login do
    name    = Util.ask("What's you username")
    address = Util.ask("What's the server address") |> String.to_charlist() |> :inet.parse_address() |> elem(1)
    port    = Util.ask("What port would you like to connect to") |> String.to_integer()
    %GlowClient{username: name, address: address, port: port}
  end

  defp max_length, do: 1024

  defp help_message, do: """
    /help       Displays this message.
    /exit       Exits the program and stops the connection.
  """

  defp is_command(message), do: String.first(message) == "/"

  defp handle_message(client) do
    input = IO.gets(client.username <> ">")
    if is_command(input) do
      handle_command(client, input)
    end
    handle_message(client)
  end

  defp listen(client) do
    case :gen_tcp.recv(client.socket, 0) do
      {:ok, message} -> IO.puts(message)
      {:error, reason} -> exit(reason)
    end
    listen(client)
  end

  defp handle_command(client, command) do
    case command do
      "/help" -> help_message() |> IO.puts()
      "/exit" -> exit("Exit command ran, program terminating")
      _ -> IO.puts("Unrecognized command of: " <> command)
    end
  end
end
