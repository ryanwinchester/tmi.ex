defmodule TMI.Handlers.LoginHandler do
  @moduledoc false

  use GenServer

  require Logger

  alias TMI.Conn

  @tmi_capabilities ['membership', 'tags', 'commands']

  def start_link(%Conn{} = conn) do
    GenServer.start_link(__MODULE__, conn)
  end

  ## Callbacks

  @impl true
  def init(%Conn{} = conn) do
    ExIRC.Client.add_handler(conn.client, self())
    {:ok, conn}
  end

  @impl true
  def handle_info(:logged_in, conn) do
    Logger.debug("Logged in to #{conn.server}:#{conn.port}")
    Enum.each(conn.caps, &request_capabilities(conn.client, &1))
    Enum.each(conn.channels, &join_channel(conn.client, &1))
    {:noreply, conn}
  end

  # Catch-all for messages you don't care about
  def handle_info(msg, conn) do
    Logger.debug("Unhandled msg: #{inspect(msg)}")
    {:noreply, conn}
  end

  ## Helpers

  defp request_capabilities(client, cap) when cap in @tmi_capabilities do
    Logger.debug("Requesting #{cap} capability...")
    cmd = ExIRC.Commands.command!('CAP REQ :twitch.tv/#{cap}')
    :ok = ExIRC.Client.cmd(client, cmd)
  end

  defp request_capabilities(_client, cap), do: raise("Invalid capability #{cap}")

  defp join_channel(client, channel) do
    Logger.debug("Joining channel #{channel}...")
    :ok = ExIRC.Client.join(client, channel)
  end
end
