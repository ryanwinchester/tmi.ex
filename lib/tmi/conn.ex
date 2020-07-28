defmodule TMI.Conn do
  @moduledoc false

  defstruct(
    server: "irc.chat.twitch.tv",
    port: 6697,
    pass: nil,
    nick: nil,
    user: nil,
    name: nil,
    client: nil,
    channels: []
  )

  @type t :: %__MODULE__{
          server: String.t(),
          port: integer,
          pass: String.t(),
          nick: String.t(),
          user: String.t(),
          name: String.t(),
          client: pid,
          channels: [String.t()]
        }

  def new(client, user, pass, channels) do
    %__MODULE__{
      client: client,
      name: user,
      nick: user,
      user: user,
      pass: pass,
      channels: channels
    }
  end
end
