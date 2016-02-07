defmodule TestServer do
  use Plug.Router
  require IEx

  plug :match
  plug :dispatch

  @port Application.get_env(:sendalot, Sendalot)[:test_server_port]
  @host Application.get_env(:sendalot, Sendalot)[:test_server_host]

  post _ do
    sender = Map.new(conn.req_headers)["senderid"]
    {:ok, message, _conn} = Plug.Conn.read_body(conn)
    update_messages_for sender, message
    test_store = Agent.get(:test_server, fn store -> store end)
    send_resp(conn, 200, "Message: #{message} from #{sender}")
  end

  def start do
    Plug.Adapters.Cowboy.http TestServer, [], port: @port, ref: :test_server
    Agent.start_link(fn -> Map.new end, name: :test_server)
  end

  def stop do
    Plug.Adapters.Cowboy.shutdown :test_server
  end

  def port, do: @port
  def host, do: @host
  
  defp update_messages_for sender, message do
    store = Agent.get(:test_server, fn store -> store end)
    messages = Map.get(store, sender)
               |> update_messages(message)
    Agent.update(:test_server, fn stor -> Map.put(stor, sender, messages) end)
  end

  defp update_messages nil, message do
    [message]
  end
  defp update_messages messages, message do
    messages ++ [message]
  end
end
