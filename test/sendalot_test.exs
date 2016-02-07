defmodule SendalotTest do
  use ExUnit.Case
  doctest Sendalot
  @server "#{TestServer.host}:#{TestServer.port}" 

  setup do
    TestServer.start
    :ok
  end

  test "sends a list of messages from a sender to a server" do
    messages = ["message1", "message2", "message3"]
    Sendalot.send_messages_from_shard_to_server messages, :sender1,  @server
    test_store = Agent.get(:test_server, fn store -> store end)
    assert Map.get(test_store, "sender1") == messages
  end

  test "sends a list of messages from a list of senders to a server" do
    messages = ["message1", "message2", "message3"]
    senders = ["sendera", "senderb", "senderc"]
    tasks = Sendalot.send_messages_from_shards_to_server messages, senders,  @server
    tasks |> Enum.each(fn(t) -> Task.await(t) end)
    test_store = Agent.get(:test_server, fn store -> store end)
    Enum.each(senders,
              fn(s) -> 
                assert Map.get(test_store, s) == messages end)
  end

  test "sends n messages from m shards" do
    tasks = Sendalot.send_n_messages_from_m_shards_to_server 43, 23, @server
    messages = Enum.map((1..43), fn(x) -> Integer.to_string(x) end)
    tasks |> Enum.each(fn(t) -> Task.await(t) end)
    test_store = Agent.get(:test_server, fn store -> store end)
    (1..23)
    |> Enum.map(fn(i) -> Integer.to_string(i) end)
    |> Enum.each(fn(s) -> assert Map.get(test_store, s) == messages end)
  end
end
