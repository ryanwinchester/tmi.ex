defmodule TMI.Client do
  @moduledoc """
  TMI Client wrapper.
  """

  alias ExIRC.Client

  alias TMI.Conn

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
  end

  @doc """
  Get a list of users in the provided channel.
  """
  @spec channel_users(Conn.t(), String.t()) ::
          [String.t()] | {:error, :not_connected | :not_logged_in | :no_such_channel}
  def channel_users(%Conn{} = conn, channel) do
    Client.channel_users(conn.client, normalize_channel(channel))
  end

  @doc """
  Determine if a user is present in the provided channel.
  """
  @spec channel_has_user?(Conn.t(), String.t(), String.t()) ::
          boolean() | {:error, :not_connected | :not_logged_in | :no_such_channel}
  def channel_has_user?(%Conn{} = conn, channel, user) do
    Client.channel_has_user?(conn.client, normalize_channel(channel), user)
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
    Client.connect_ssl!(conn.client, conn.server, conn.port)
  end

  @doc """
  Kick a user from a channel.
  """
  @spec kick(Conn.t(), String.t(), String.t(), String.t()) ::
          :ok | {:error, :not_connected | :not_logged_in}
  def kick(conn, channel, user, message \\ "") do
    Client.kick(conn.client, channel, user, message)
  end

  @doc """
  Logon to a server.
  """
  @spec logon(Conn.t()) :: :ok | {:error, :not_connected}
  def logon(%Conn{} = conn) do
    Client.logon(conn.client, conn.pass, conn.nick, conn.user, conn.name)
  end

  @doc """
  Join a channel.
  """
  @spec join(Conn.t(), String.t()) :: :ok | {:error, :not_connected | :not_logged_in}
  def join(%Conn{} = conn, channel) do
    Client.join(conn.client, normalize_channel(channel))
  end

  @doc """
  Leave a channel.
  """
  @spec part(Conn.t(), String.t()) :: :ok | {:error, :not_connected | :not_logged_in}
  def part(%Conn{} = conn, channel) do
    Client.part(conn.client, normalize_channel(channel))
  end

  @doc """
  Quit the server.
  """
  @spec quit(Conn.t(), String.t()) :: :ok | {:error, :not_connected | :not_logged_in}
  def quit(%Conn{} = conn, msg) do
    Client.quit(conn.client, msg)
  end

  @doc """
  Stop the client process.
  """
  @spec stop(Conn.t()) :: :ok
  def stop(%Conn{} = conn) do
    Client.stop!(conn.client)
  end

  @doc """
  Send a raw IRC command to TMI IRC server.
  """
  @spec cmd(Conn.t(), String.t() | charlist()) :: :ok | {:error, :not_connected | :not_logged_in}
  def cmd(%Conn{} = conn, command) do
    Client.cmd(conn.client, command)
  end

  @doc """
  Send a channel message.
  """
  @spec say(Conn.t(), String.t(), String.t()) ::
          :ok | {:error, :not_connected | :not_logged_in}
  def say(%Conn{} = conn, channel, message) do
    Client.msg(conn.client, :privmsg, normalize_channel(channel), message)
  end

  @doc """
  Send a whisper message to a user.
  """
  @spec whisper(Conn.t(), String.t(), String.t()) ::
          :ok | {:error, :not_connected | :not_logged_in}
  def whisper(%Conn{} = conn, user, message) do
    Client.msg(conn.client, :privmsg, user, message)
  end

  @doc """
  Send an action message, i.e. (/me slaps someone with a big trout)
  """
  @spec action(Conn.t(), String.t(), String.t()) ::
          :ok | {:error, :not_connected | :not_logged_in}
  def action(%Conn{} = conn, channel, message) do
    Client.me(conn.client, normalize_channel(channel), message)
  end

  @doc """
  Map channel names to channel names with the prepended "#".

  ## Examples

      iex> TMI.Client.normalize_channel("#foo")
      "#foo"

      iex> TMI.Client.normalize_channel("bar")
      "#bar"

  """
  def normalize_channel("#" <> _ = channel), do: channel
  def normalize_channel(channel), do: "#" <> channel
end
