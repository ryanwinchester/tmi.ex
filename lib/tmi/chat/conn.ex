defmodule TMI.Chat.Conn do
  @moduledoc false

  @type client :: pid() | nil
  @type port_number :: :inet.port_number()
  @type server :: :inet.hostname()
  @type pass :: String.t()
  @type user :: String.t()
  @type cap :: String.t() | atom() | charlist()
  @type channel :: String.t()

  @type t :: %__MODULE__{
          server: server(),
          port: port_number(),
          pass: pass(),
          user: user(),
          client: client(),
          caps: [cap()],
          channels: [channel()]
        }

  @default_server "irc.chat.twitch.tv"
  @default_port 6697

  # We do not want the password showing up in logs and such.
  @derive {Inspect, except: [:pass]}

  @enforce_keys [:client, :user, :pass, :channels]

  defstruct(
    pass: "",
    user: "",
    client: nil,
    channels: [],
    caps: [~c"membership", ~c"tags", ~c"commands"],
    server: @default_server,
    port: @default_port
  )

  @doc """
  Create a new conn struct.

  ## Example

      iex> TMI.Chat.Conn.new(:some_pid, "user", "pass", ["mychannel"], [])
      %TMI.Chat.Conn{
        server: "irc.chat.twitch.tv",
        port: 6697,
        user: "user",
        pass: "pass",
        client: :some_pid,
        caps: [],
        channels: ["mychannel"]
      }

  """
  @spec new(client(), user(), pass(), [channel()], [cap()]) :: t()
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
