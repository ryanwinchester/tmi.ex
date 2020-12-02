defmodule TMI.Client do
  alias TMI.Conn

  require Logger

  defdelegate start_link!(), to: ExIRC

  @doc """
  Determine if the provided client process has an open connection to a server.
  """
  @spec is_connected?(Conn.t()) :: true | false
  def is_connected?(%Conn{} = conn) do
    ExIRC.Client.is_connected?(conn.client)
  end

  @doc """
  Determine if the provided client is logged on to a server.
  """
  @spec is_logged_on?(Conn.t()) :: true | false
  def is_logged_on?(%Conn{} = conn) do
    ExIRC.Client.is_logged_on?(conn.client)
  end

  @doc """
  Get a list of users in the provided channel.
  """
  @spec chat_users(Conn.t(), chat :: String.t()) :: list(String.t()) | [] | {:error, atom}
  def chat_users(%Conn{} = conn, chat) do
    ExIRC.Client.channel_users(conn.client, chat_to_channel(chat))
  end

  @doc """
  Determine if a user is present in the provided chat.
  """
  @spec chat_has_user?(Conn.t(), chat :: String.t(), user :: String.t()) ::
          true | false | {:error, atom}
  def chat_has_user?(%Conn{} = conn, chat, user) do
    ExIRC.Client.channel_has_user?(conn.client, chat_to_channel(chat), user)
  end

  ## Chainable (returns Conn.t())

  @doc """
  Add a new event handler process.
  """
  def add_handler(%Conn{} = conn, handler) do
    log_error(ExIRC.Client.add_handler(conn.client, handler), :add_handler)
    conn
  end

  @doc """
  Add a new event handler process, asynchronously.
  """
  def add_handler_async(%Conn{} = conn, handler) do
    log_error(ExIRC.Client.add_handler_async(conn.client, handler), :add_handler_async)
    conn
  end

  @doc """
  Remove an event handler process.
  """
  def remove_handler(%Conn{} = conn, handler) do
    log_error(ExIRC.Client.remove_handler(conn.client, handler), :remove_handler)
    conn
  end

  @doc """
  Remove an event handler process, asynchronously
  """
  def remove_handler_async(%Conn{} = conn, handler) do
    log_error(ExIRC.Client.remove_handler_async(conn.client, handler), :remove_handler_async)
    conn
  end

  @doc """
  Connect to a server with the provided server and port.
  """
  def connect!(%Conn{} = conn) do
    log_error(ExIRC.Client.connect!(conn.client, conn.server, conn.port), :connect)
    conn
  end

  @doc """
  Connect to a server with the provided server and port via SSL.
  """
  def connect_ssl!(%Conn{} = conn) do
    log_error(ExIRC.Client.connect_ssl!(conn.client, conn.server, conn.port), :connect_ssl)
    conn
  end

  @doc """
  Logon to a server.
  """
  def logon(%Conn{} = conn) do
    log_error(ExIRC.Client.logon(conn.client, conn.pass, conn.nick, conn.user, conn.name), :logon)
    conn
  end

  @doc """
  Join a chat.
  """
  def join(%Conn{} = conn, chat) do
    log_error(ExIRC.Client.join(conn.client, chat_to_channel(chat)), :join)
    conn
  end

  @doc """
  Leave a chat.
  """
  def part(%Conn{} = conn, chat) do
    log_error(ExIRC.Client.part(conn.client, chat_to_channel(chat)), :part)
    conn
  end

  @doc """
  Quit the server.
  """
  def quit(%Conn{} = conn, msg) do
    log_error(ExIRC.Client.quit(conn.client, msg), :quit)
    conn
  end

  @doc """
  Stop the client process.
  """
  def stop!(%Conn{} = conn) do
    log_error(ExIRC.Client.stop!(conn.client), :stop)
    conn
  end

  @doc """
  Send a raw IRC command to TMI IRC server.
  """
  def command(%Conn{} = conn, command) do
    cmd = ExIRC.Commands.command!(command)
    log_error(ExIRC.Client.cmd(conn.client, cmd), :command)
    conn
  end

  @doc """
  Send a chat message.
  """
  def message(%Conn{} = conn, chat, message) do
    log_error(ExIRC.Client.msg(conn.client, :privmsg, chat_to_channel(chat), message), :message)
    conn
  end

  @doc """
  Send a whisper message to a user.
  """
  def whisper(%Conn{} = conn, user, message) do
    log_error(ExIRC.Client.msg(conn.client, :privmsg, user, message), :whisper)
    conn
  end

  @doc """
  Send an action message, i.e. (/me slaps someone with a big trout)
  """
  def action(%Conn{} = conn, chat, message) do
    log_error(ExIRC.Client.me(conn.client, chat_to_channel(chat), message), :action)
    conn
  end

  @doc """
  Map chat names to channel names with the prepended "#".

  ## Examples

      iex> TMI.Client.chat_to_channel("#foo")
      "#foo"

      iex> TMI.Client.chat_to_channel("bar")
      "#bar"

  """
  def chat_to_channel("#" <> _ = channel), do: channel
  def chat_to_channel(chat), do: "#" <> chat

  defp log_error(:ok, _caller), do: :ok
  defp log_error({:error, reason}, caller) do
    Logger.error("[Client] #{caller} errored: #{reason}")
  end
end
