defmodule TMI.Handlers.LoginHandler do
  @moduledoc false

  use GenServer

  require Logger

  alias TMI.Client
  alias TMI.Conn

  @tmi_capabilities ['membership', 'tags', 'commands']

  def start_link(%Conn{} = conn) do
    GenServer.start_link(__MODULE__, conn, name: __MODULE__)
  end

  ## Callbacks

  @impl true
  def init(%Conn{} = conn) do
    Client.add_handler(conn, self())
    {:ok, conn}
  end

  @impl true
  def handle_info(:logged_in, conn) do
    Logger.debug("[TMI] Logged in to #{conn.server}:#{conn.port}")
    Enum.each(conn.caps, &request_capabilities(conn, &1))
    Enum.each(conn.chats, &join_chat(conn, &1))
    {:noreply, conn}
  end

  # Catch-all for messages we don't care about.
  def handle_info(_msg, conn), do: {:noreply, conn}

  ## Helpers

  defp request_capabilities(conn, cap) when cap in @tmi_capabilities do
    Logger.debug("[TMI] Requesting #{cap} capability...")
    Client.command(conn, 'CAP REQ :twitch.tv/#{cap}')
  end

  # If you know what you're doing, you can request other capabilities ¯\_(ツ)_/¯
  defp request_capabilities(conn, cap) do
    Logger.warn("[TMI] Requesting NON-TMI capability: #{cap}...")
    Client.command(conn, to_charlist(cap))
  end

  defp join_chat(conn, chat) do
    Logger.debug("[TMI] Joining chat #{chat}...")
    Client.join(conn, chat)
  end
end
