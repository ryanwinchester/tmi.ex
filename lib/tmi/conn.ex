defmodule TMI.Conn do
  @moduledoc false

  defstruct(
    server: "irc.chat.twitch.tv",
    port: 6697,
    pass: "",
    user: "",
    client: nil,
    caps: [],
    channels: []
  )

  @type t :: %__MODULE__{
          server: String.t(),
          port: pos_integer(),
          pass: String.t(),
          user: String.t(),
          client: pid() | nil,
          caps: [String.t() | atom | charlist],
          channels: [String.t()]
        }

  @doc """
  Create a new conn struct.

  ## Example

      iex> TMI.Conn.new(:some_pid, "user", "pass", ["mychannel"], [])
      %TMI.Conn{
        server: "irc.chat.twitch.tv",
        port: 6697,
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
      user: user,
      pass: pass,
      caps: caps,
      channels: channels
    }
  end
end
