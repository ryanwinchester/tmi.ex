defmodule TMI.Chat.Client do
  @moduledoc """
  TMI wrapper for ExIRC.Client.
  """

  alias ExIRC.Client

  alias TMI.Chat.Conn

  require Logger

  defdelegate start_link(opts \\ []), to: ExIRC.Client

  @doc """
  Determine if the provided client process has an open connection to a server.
  """
  @spec is_connected?(Conn.t()) :: boolean()
  def is_connected?(%Conn{} = conn) do
    Client.is_connected?(conn.client)
  end

  @doc """
  Determine if the provided client is logged on to a server.
  """
  @spec is_logged_on?(Conn.t()) :: boolean() | {:error, :not_connected}
  def is_logged_on?(%Conn{} = conn) do
    Client.is_logged_on?(conn.client)
    |> expect()
  end

  @doc """
  Get a list of users in the provided channel.
  """
  @spec channel_users(Conn.t(), String.t()) ::
          [String.t()] | {:error, :not_connected | :not_logged_in | :no_such_channel}
  def channel_users(%Conn{} = conn, channel) do
    Client.channel_users(conn.client, normalize_channel(channel))
    |> expect("couldn't fetch channel users")
  end

  @doc """
  Determine if a user is present in the provided channel.
  """
  @spec channel_has_user?(Conn.t(), String.t(), String.t()) ::
          boolean() | {:error, :not_connected | :not_logged_in | :no_such_channel}
  def channel_has_user?(%Conn{} = conn, channel, user) do
    Client.channel_has_user?(conn.client, normalize_channel(channel), user)
    |> expect("couldn't check for channel user")
  end

  @doc """
  Add a new event handler process.
  """
  @spec add_handler(Conn.t(), pid()) :: :ok
  def add_handler(%Conn{} = conn, handler) do
    Client.add_handler(conn.client, handler)
  end

  @doc """
  Add a new event handler process, asynchronously.
  """
  @spec add_handler_async(Conn.t(), pid()) :: :ok
  def add_handler_async(%Conn{} = conn, handler) do
    Client.add_handler_async(conn.client, handler)
  end

  @doc """
  Remove an event handler process.
  """
  @spec remove_handler(Conn.t(), pid()) :: :ok
  def remove_handler(%Conn{} = conn, handler) do
    Client.remove_handler(conn.client, handler)
  end

  @doc """
  Remove an event handler process, asynchronously
  """
  @spec remove_handler_async(Conn.t(), pid()) :: :ok
  def remove_handler_async(%Conn{} = conn, handler) do
    Client.remove_handler_async(conn.client, handler)
  end

  @doc """
  Connect to a server with the provided server and port via SSL.
  """
  @spec connect_ssl(Conn.t()) :: :ok | {:error, any()}
  def connect_ssl(%Conn{} = conn) do
    Client.connect_ssl!(conn.client, conn.server, conn.port,
      verify: :verify_peer,
      cacertfile: CAStore.file_path() |> to_charlist()
    )
    |> expect("couldn't connect to SSL")
  end

  @doc """
  Kick a user from a channel.
  """
  @spec kick(Conn.t(), String.t(), String.t(), String.t()) ::
          :ok | {:error, :not_connected | :not_logged_in}
  def kick(conn, channel, user, message \\ "") do
    Client.kick(conn.client, channel, user, message)
    |> expect("couldn't kick #{user} from #{channel}")
  end

  @doc """
  Logon to a server.

  Your nickname (`nick`) must be your Twitch username (login name) in lowercase.

  A successful connection session looks like the following example:

      < PASS oauth:<Twitch OAuth token>
      < NICK <user>
      > :tmi.twitch.tv 001 <user> :Welcome, GLHF!
      > :tmi.twitch.tv 002 <user> :Your host is tmi.twitch.tv
      > :tmi.twitch.tv 003 <user> :This server is rather new
      > :tmi.twitch.tv 004 <user> :-
      > :tmi.twitch.tv 375 <user> :-
      > :tmi.twitch.tv 372 <user> :You are in a maze of twisty passages.
      > :tmi.twitch.tv 376 <user> :>

  """
  @spec logon(Conn.t()) :: :ok | {:error, :not_connected}
  def logon(%Conn{} = conn) do
    Client.logon(conn.client, conn.pass, String.downcase(conn.user), conn.user, conn.user)
    |> expect("couldn't logon")
  end

  @doc """
  Join a channel.
  """
  @spec join(Conn.t(), String.t()) :: :ok | {:error, :not_connected | :not_logged_in}
  def join(%Conn{} = conn, channel) do
    Client.join(conn.client, normalize_channel(channel))
    |> expect("couldn't join channel #{channel}")
  end

  @doc """
  Leave a channel.
  """
  @spec part(Conn.t(), String.t()) :: :ok | {:error, :not_connected | :not_logged_in}
  def part(%Conn{} = conn, channel) do
    Client.part(conn.client, normalize_channel(channel))
    |> expect("couldn't part channel #{channel}")
  end

  @doc """
  Quit the server.
  """
  @spec quit(Conn.t(), String.t()) :: :ok | {:error, :not_connected | :not_logged_in}
  def quit(%Conn{} = conn, msg) do
    Client.quit(conn.client, msg)
    |> expect("couldn't quit")
  end

  @doc """
  Stop the client process.
  """
  @spec stop!(Conn.t()) :: :ok
  def stop!(%Conn{} = conn) do
    :ok = Client.stop!(conn.client)
  end

  @doc """
  Send a raw IRC command to TMI IRC server.
  """
  @spec command(Conn.t(), iodata()) :: :ok
  def command(%Conn{} = conn, command) do
    Client.cmd(conn.client, command)
  end

  @doc """
  Send a channel message.
  """
  @spec say(Conn.t(), String.t(), iodata()) ::
          :ok | {:error, :not_connected | :not_logged_in}
  def say(%Conn{} = conn, channel, message) do
    Client.msg(conn.client, :privmsg, normalize_channel(channel), message)
    |> expect("couldn't send message to channel #{channel}")
  end

  @doc """
  Send a whisper message to a user.
  """
  @spec whisper(Conn.t(), String.t(), iodata()) ::
          :ok | {:error, :not_connected | :not_logged_in}
  def whisper(%Conn{} = conn, user, message) do
    Client.msg(conn.client, :privmsg, user, message)
    |> expect("couldn't whisper to user #{user}")
  end

  @doc """
  Send an action message, i.e. (/me slaps someone with a big trout)
  """
  @spec me(Conn.t(), String.t(), iodata()) ::
          :ok | {:error, :not_connected | :not_logged_in}
  def me(%Conn{} = conn, channel, message) do
    Client.me(conn.client, normalize_channel(channel), message)
    |> expect("couldn't do `me` action in channel #{channel}")
  end

  @doc """
  Get a list of the channels the client has joined.
  """
  @spec list_channels(Conn.t()) :: [String.t()] | {:error, :not_connected | :not_logged_in}
  def list_channels(conn) do
    Client.channels(conn.client)
  end

  @doc """
  Map channel names to channel names with the prepended "#".

  ## Examples

      iex> normalize_channel("#foo")
      "#foo"

      iex> normalize_channel("foo")
      "#foo"

  """
  def normalize_channel("#" <> _ = channel), do: channel
  def normalize_channel(channel), do: "#" <> channel

  # Log error if result is an error.
  defp expect(result, message \\ "")

  defp expect({:error, reason} = error, message) do
    Logger.error("[TMI.Chat.Client] [#{inspect(reason)}] #{message}")
    error
  end

  defp expect(success, _failed_message), do: success
end
