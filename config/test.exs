use Mix.Config
config :sendalot, Sendalot, test_server_port: 6563
config :sendalot, Sendalot, test_server_host: "localhost" 
config :sendalot, Sendalot, shard_header: "senderid" 
