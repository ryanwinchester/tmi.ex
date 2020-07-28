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

  @doc """
  Create a new conn struct.

  ## Example

      iex> TMI.Conn.new(:some_pid, "user", "pass", ["mychat"])
      %TMI.Conn{
        server: "irc.chat.twitch.tv",
        port: 6697,
        name: "user",
        nick: "user",
        user: "user",
        pass: "pass",
        client: :some_pid,
        channels: ["#mychat"]
      }

  """
  def new(client, user, pass, chats) do
    %__MODULE__{
      client: client,
      name: user,
      nick: user,
      user: user,
      pass: pass,
      channels: Enum.map(chats, &chat_to_channel/1)
    }
  end

  @doc """
  Map chat names to channel names with the prepended "#".

  ## Examples

      iex> TMI.Conn.chat_to_channel("#foo")
      "#foo"

      iex> TMI.Conn.chat_to_channel("bar")
      "#bar"

  """
  def chat_to_channel("#" <> _ = channel), do: channel
  def chat_to_channel(chat), do: "#" <> chat
end
