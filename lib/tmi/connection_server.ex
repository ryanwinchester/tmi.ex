defmodule TMI.ConnectionServer do
  @moduledoc false
  use GenServer

  require Logger

  alias TMI.ChannelServer
  alias TMI.Client
  alias TMI.Conn

  @tmi_capabilities ['membership', 'tags', 'commands']

  # ----------------------------------------------------------------------------
  # Public API
  # ----------------------------------------------------------------------------

  @doc """
  Start the connection handler.
  """
  @spec start_link({module(), Conn.t()}) :: GenServer.on_start()
  def start_link({bot, conn}) do
    GenServer.start_link(__MODULE__, {bot, conn}, name: module_name(bot))
  end

  @doc """
  Get the bot-specific module name.
  """
  @spec module_name(module()) :: module()
  def module_name(bot) do
    Module.concat([bot, "ConnectionServer"])
  end

  # ----------------------------------------------------------------------------
  # GenServer callbacks
  # ----------------------------------------------------------------------------

  @doc """
  Invoked when the server is started. `start_link/3` will block until it
  returns.
  """
  @impl GenServer
  def init({bot, conn}) do
    Client.add_handler(conn, self())
    {:ok, %{bot: bot, conn: conn}, {:continue, :connect}}
  end

  @doc """
  Invoked to handle `continue` instructions.

  It is useful for performing work after initialization or for splitting the
  work in a callback in multiple steps, updating the process state along the
  way.
  """
  @impl GenServer
  def handle_continue(:connect, state) do
    connect(state.conn)
    {:noreply, state}
  end

  @doc """
  Invoked to handle all other messages.

  For example calling `Process.send_after(self(), :foo, 1000)` would send `:foo`
  after one second, and we could match on that here.
  """
  @impl GenServer
  def handle_info(:connect, state) do
    unless Client.is_connected?(state.conn.client) do
      connect(state.conn)
    end

    {:noreply, state}
  end

  def handle_info({:connected, _server, _port}, %{conn: conn} = state) do
    case Client.logon(conn) do
      :ok ->
        Logger.info("[TMI.ConnectionServer] LOGGED IN as #{conn.user}")

      {:error, :not_connected} ->
        Logger.error("[TMI.ConnectionServer] Cannot LOG IN, not connected")
    end

    {:noreply, state}
  end

  def handle_info(:logged_in, %{conn: conn} = state) do
    Logger.debug("[TMI] Logged in to #{conn.server}:#{conn.port}")
    Enum.each(conn.caps, &request_capabilities(conn, &1))
    Enum.each(conn.channels, &join_channel(state.bot, &1))
    {:noreply, state}
  end

  def handle_info(:disconnected, %{conn: conn} = state) do
    Logger.info("[TMI.ConnectionServer] Disconnected from #{conn.server}:#{conn.port}")
    {:stop, :normal, state}
  end

  def handle_info({:disconnected, "@" <> _cmd, _msg}, %{conn: conn} = state) do
    Logger.info("[TMI.ConnectionServer] Disconnected from #{conn.server}:#{conn.port}")
    {:noreply, state}
  end

  def handle_info({:notice, msg, _sender}, state) do
    Logger.error("[TMI.ConnectionServer] NOTICE: #{msg}")
    {:noreply, state}
  end

  # Catch-all for unhandled.
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  # Quit the channels and close the underlying client connection when the
  # process is terminating.
  @impl GenServer
  def terminate(_, %{conn: conn}) do
    Logger.warn("[TMI.ConnectionServer] Terminating...")
    Client.quit(conn, "[TMI.ConnectionServer] Goodbye, cruel world.")
    Client.stop(conn)
  end

  # ----------------------------------------------------------------------------
  # Internal API
  # ----------------------------------------------------------------------------

  defp connect(%Conn{} = conn) do
    case Client.connect_ssl(conn) do
      :ok ->
        Logger.info("[TMI.ConnectionServer] Connected to #{conn.server}:#{conn.port}...")
        :ok

      {:error, reason} ->
        Logger.error("[TMI.ConnectionServer] Unable to connect: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp request_capabilities(conn, cap) when cap in @tmi_capabilities do
    Logger.info("[TMI.ConnectionServer] Requesting #{cap} capability...")
    Client.command(conn, ['CAP REQ :twitch.tv/', cap])
  end

  # If you know what you're doing, you can request other capabilities ¯\_(ツ)_/¯
  defp request_capabilities(conn, cap) do
    Logger.warn("[TMI.ConnectionServer] Requesting NON-TMI capability: #{cap}...")
    Client.command(conn, to_charlist(cap))
  end

  defp join_channel(bot, channel) do
    Logger.debug("[TMI.ConnectionServer] Joining channel #{channel}...")
    ChannelServer.join(bot, channel)
  end
end
