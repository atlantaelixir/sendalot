defmodule Sendalot do
  @doc """
  Sends a test with a header to message to the specified server
  ### Examples
    ```
    iex> Sendalot.send_message_from_shard_to_server("messages", "shard", "localhost:6563") |> elem(1) |> Map.get(:body)
    "Message: messages from shard"

    ```
  """
  @shard_header Application.get_env(:sendalot, Sendalot)[:shard_header]

  def send_message_from_shard_to_server message, shard, server do
    response = HTTPoison.post server, message, %{"#{@shard_header}": shard}
  end 
  
  def send_messages_from_shard_to_server messages, shard, server do
    messages
    |> Enum.each(fn(m) -> send_message_from_shard_to_server m, shard, server end)
  end

  def send_messages_from_shards_to_server messages, shards, server do
    shards
    |> Enum.map(fn(s) -> Task.async(fn -> send_messages_from_shard_to_server(messages, s, server) end) end)
  end

  def send_n_messages_from_m_shards_to_server message_count, shard_count, server do
    messages = Enum.map((1..message_count), fn(i) -> Integer.to_string(i) end)
    send_messages_from_shards_to_server messages, (1..shard_count), server
  end
end
