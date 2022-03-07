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
    caps: [],
    channels: []
  )

  @type t :: %__MODULE__{
          server: String.t(),
          port: integer,
          pass: String.t(),
          name: String.t(),
          nick: String.t(),
          user: String.t(),
          client: pid,
          caps: [String.t() | atom | charlist],
          channels: [String.t()]
        }

  @doc """
  Create a new conn struct.

  ## Example

      iex> TMI.Conn.new(:some_pid, "user", "pass", ["mychannel"], [])
      %TMI.Conn{
        server: "irc.channel.twitch.tv",
        port: 6697,
        name: "user",
        nick: "user",
        user: "user",
        pass: "pass",
        client: :some_pid,
        caps: [],
        channels: ["mychannel"]
      }

  """
  def new(client, user, pass, channels, caps) do
    %__MODULE__{
      client: client,
      name: user,
      nick: user,
      user: user,
      pass: pass,
      caps: caps,
      channels: channels
    }
  end
end
