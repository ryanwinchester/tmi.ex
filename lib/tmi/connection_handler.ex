defmodule TMI.ConnectionHandler do
  @moduledoc false
  use GenServer

  require Logger

  alias ExIRC.Client

  alias TMI.ChannelServer
  alias TMI.Conn

  @tmi_capabilities ['membership', 'tags', 'commands']

  @doc """
  Start the connection handler.
  """
  @spec start_link({module(), Conn.t()}) :: GenServer.on_start()
  def start_link({bot, conn}) do
    name = Module.concat([bot, "ConnectionHandler"])
    GenServer.start_link(__MODULE__, {bot, conn}, name: name)
  end

  ## Callbacks

  @impl GenServer
  def init({bot, conn}) do
    Client.add_handler(conn, self())
    {:ok, %{bot: bot, conn: conn}, {:continue, :connect}}
  end

  @impl GenServer
  def handle_continue(:connect, state) do
    connect(state.conn)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:connect, state) do
    unless Client.is_connected?(state.conn.client) do
      connect(state.conn)
    end

    {:noreply, state}
  end

  def handle_info({:connected, _server, _port}, %{conn: conn} = state) do
    case Client.logon(conn.client, conn.pass, conn.user, conn.user, conn.user) do
      :ok ->
        Logger.info("[TMI.ConnectionHandler] LOGGED IN as #{conn.user}")

      {:error, :not_connected} ->
        Logger.error("[TMI.ConnectionHandler] Cannot LOG IN, not connected")
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
    Logger.info("[TMI.ConnectionHandler] Disconnected from #{conn.server}:#{conn.port}")
    {:stop, :normal, state}
  end

  def handle_info({:disconnected, "@" <> _cmd, _msg}, %{conn: conn} = state) do
    Logger.info("[TMI.ConnectionHandler] Disconnected from #{conn.server}:#{conn.port}")
    {:noreply, state}
  end

  def handle_info({:notice, msg, _sender}, state) do
    Logger.error("[TMI.ConnectionHandler] NOTICE: #{msg}")
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
    Logger.warn("[TMI.ConnectionHandler] Terminating...")
    Client.quit(conn.client, "[TMI.ConnectionHandler] Goodbye, cruel world.")
    Client.stop!(conn.client)
  end

  ## Helpers

  defp connect(%Conn{} = conn) do
    case Client.connect_ssl!(conn.client, conn.server, conn.port) do
      :ok ->
        Logger.info("[TMI.ConnectionHandler] Connected to #{conn.server}:#{conn.port}...")
        :ok

      {:error, reason} ->
        Logger.error("[TMI.ConnectionHandler] Unable to connect: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp request_capabilities(conn, cap) when cap in @tmi_capabilities do
    Logger.info("[TMI.ConnectionHandler] Requesting #{cap} capability...")
    Client.command(conn.client, ['CAP REQ :twitch.tv/', cap])
  end

  # If you know what you're doing, you can request other capabilities ¯\_(ツ)_/¯
  defp request_capabilities(conn, cap) do
    Logger.warn("[TMI.ConnectionHandler] Requesting NON-TMI capability: #{cap}...")
    Client.command(conn.client, to_charlist(cap))
  end

  defp join_channel(bot, channel) do
    Logger.debug("[TMI.ConnectionHandler] Joining channel #{channel}...")
    channel_server = Module.concat([bot, "ChannelServer"])
    channel_server.join(channel)
  end
end
