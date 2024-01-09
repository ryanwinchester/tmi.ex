import Config

config :tmi, TMI.Socket,
  user_id: "146616692",
  client_id: System.get_env("TWITCH_CLIENT_ID"),
  access_token: System.get_env("TWITCH_ACCESS_TOKEN")
