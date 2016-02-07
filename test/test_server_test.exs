defmodule TestServerTest do
  use ExUnit.Case, async: false

  setup do
    TestServer.start
    :ok
  end

  test "the test server is running" do
    {:ok, response} = HTTPoison.post "localhost:#{TestServer.port}", "Give the dog a bone", %{"SenderID": "Paddywack"}
    assert response.body == "Message: Give the dog a bone from Paddywack"
  end

  test "The test server stores messages and senders" do
    HTTPoison.post "localhost:#{TestServer.port}", "Give the dog a bone", %{"SenderID": "Paddywack"}
    HTTPoison.post "localhost:#{TestServer.port}", "I'm lost", %{"SenderID": "Clementine"}
    test_store = Agent.get(:test_server, fn store -> store end)
    assert Map.get(test_store, "Clementine") == ["I'm lost"]
    assert Map.get(test_store, "Paddywack") == ["Give the dog a bone"]
  end
end
