defmodule GlowServer do
  defstruct [:port, :max_connections]

  @type client_events :: :new_client
    | :remove_client
    | :send_all
    | :max_connection_check

  def start do
    server = setup()
    {:ok, socket} = :gen_tcp.listen(server.port, [:binary, packet: :raw, active: false, reuseaddr: true])

    IO.puts("Server listening on port: #{server.port}")
    
    client_manager = spawn(fn -> client_manager([]) end)
    accept(socket, client_manager, server.max_connections)
  end

  defp setup do
    port            = Util.ask("What port is the server being served on") |> String.to_integer()
    max_connections = Util.ask("What is the maximum number of client connections for the server") |> String.to_integer()
    %GlowServer{port: port, max_connections: max_connections}
  end

  defp accept(socket, client_manager, max_connections) do
    {:ok, client} = :gen_tcp.accept(socket)
    send(client_manager, {:new_client, client})

    send(client_manager, {:max_connections_check, client, max_connections})

    spawn(fn -> handle_client(client, client_manager) end)
    accept(socket, client_manager, max_connections)
  end

  defp handle_client(socket, client_manager) do
    IO.puts("Handling client #{inspect(socket)}")
    case :gen_tcp.recv(socket, 0) do
      {:ok, message} ->
        IO.puts("Received: #{message}")
        send(client_manager, {:send_all, message, socket})
        handle_client(socket, client_manager)

      {:error, :closed} ->
        IO.puts("Client disconnected")
        send(client_manager, {:remove_client, socket})
        :gen_tcp.close(socket)

      {:error, reason} ->
        IO.puts(reason)
    end
  end

  defp client_manager(clients) do
    receive do
      {:new_client, client} ->
        client_manager([client | clients])

      {:remove_client, client} ->
        List.delete(clients, client) |> client_manager()

      {:send_all, message, sender} ->
        Enum.each(clients, fn client ->
          if client != sender do
            :gen_tcp.send(client, message)
          end
        end)
        client_manager(clients)

      {:max_connection_check, client, max_connections} ->
        if max_connections == length(clients) do
          :gen_tcp.send(client, "The server maximum member cap has been hit, disconnecting")
          :gen_tcp.close(client)
        end
        client_manager(clients)
    end
  end
end
