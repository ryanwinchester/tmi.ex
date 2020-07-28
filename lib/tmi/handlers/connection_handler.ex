defmodule TMI.Handlers.ConnectionHandler do
  @moduledoc false
  use GenServer

  require Logger

  alias TMI.Conn

  def start_link(%Conn{} = conn) do
    GenServer.start_link(__MODULE__, conn, name: __MODULE__)
  end

  ## Callbacks

  @impl GenServer
  def init(%Conn{} = conn) do
    Logger.debug("Connecting to #{conn.server}:#{conn.port}...")

    ExIRC.Client.add_handler(conn.client, self())
    ExIRC.Client.connect_ssl!(conn.client, conn.server, conn.port)

    {:ok, conn}
  end

  @impl GenServer
  def handle_info({:connected, _server, _port}, conn) do
    Logger.debug("Connected - Logging in as #{conn.nick}...")
    ExIRC.Client.logon(conn.client, conn.pass, conn.nick, conn.user, conn.name)
    {:noreply, conn}
  end

  def handle_info(:disconnected, conn) do
    Logger.debug("Disconnected from #{conn.server}:#{conn.port}")
    {:stop, :normal, conn}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, conn) do
    {:noreply, conn}
  end

  @impl GenServer
  def terminate(_, conn) do
    # Quit the channels and close the underlying client connection when the process is terminating
    Logger.warn("Terminating...")
    ExIRC.Client.quit(conn.client, "Goodbye, cruel world.")
    ExIRC.Client.stop!(conn.client)
    :ok
  end
end
