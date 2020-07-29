defmodule TMI.Handlers.ConnectionHandler do
  @moduledoc false
  use GenServer

  require Logger

  alias TMI.Client
  alias TMI.Conn

  def start_link(%Conn{} = conn) do
    GenServer.start_link(__MODULE__, conn, name: __MODULE__)
  end

  ## Callbacks

  @impl GenServer
  def init(%Conn{} = conn) do
    Logger.debug("[TMI] Connecting to #{conn.server}:#{conn.port}...")

    conn
    |> Client.add_handler(self())
    |> Client.connect_ssl!()

    {:ok, conn}
  end

  @impl GenServer
  def handle_info({:connected, _server, _port}, conn) do
    Logger.debug("[TMI] Connected - Logging in as #{conn.nick}...")
    Client.logon(conn)
    {:noreply, conn}
  end

  def handle_info(:disconnected, conn) do
    Logger.debug("[TMI] Disconnected from #{conn.server}:#{conn.port}")
    {:stop, :normal, conn}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, conn) do
    {:noreply, conn}
  end

  @impl GenServer
  def terminate(_, conn) do
    # Quit the channels and close the underlying client connection when the process is terminating
    Logger.warn("[TMI] Terminating...")

    conn
    |> Client.quit("[TMI] Goodbye, cruel world.")
    |> Client.stop!()

    :ok
  end
end
