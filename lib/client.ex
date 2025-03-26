defmodule GlowClient do
  defstruct [:username, :port, :socket, address: :localhost]

  def start do
    client = login()

    case :gen_tcp.connect(:localhost, client.port, [:binary, active: false]) do
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
    port    = Util.ask("What port would you like to connect to") |> String.to_integer()
    %GlowClient{username: name, port: port}
  end

  defp max_length, do: 1024

  defp is_command(message), do: String.first(message) == "/"

  defp handle_message(client) do
    input = IO.gets(client.username <> ">") |> String.trim()

    if is_command(input) do
      handle_command(client, input)
    else
      if String.length(input) <= max_length() do
        :ok = :gen_tcp.send(client.socket, "#{client.username}>#{input}")
      else
        Util.warn("Message was too long, the max character limit for messages is #{max_length()}")
      end
    end

    handle_message(client)
  end

  defp listen(client) do
    case :gen_tcp.recv(client.socket, 0) do
      {:ok, message} -> IO.puts(message)
      {:error, :closed} -> exit("Server closed connection")
      {:error, reason} -> exit(reason)
    end
    
    listen(client)
  end

  defp handle_command(_client, command) do
    alias GlowClient.Commands

    case command do
      "/help" -> Commands.help()
      "/exit" -> exit("Exit command ran, program terminating")
      _ -> IO.puts("Unrecognized command of: " <> command)
    end
  end
end


defmodule GlowClient.Commands do
  def help, do: help_message() |> IO.write()

  defp help_message, do: """
  /help       Displays this message.
  /exit       Exits the program and stops the connection.
  """
end
