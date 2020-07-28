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

    Logger.debug("Requesting capabilities...")
    Enum.each(@tmi_capabilities, &request_capabilities(conn.client, &1))

    Logger.debug("Joining channels...")
    Enum.map(conn.channels, &ExIRC.Client.join(conn.client, &1))

    {:noreply, conn}
  end

  # Catch-all for messages you don't care about
  def handle_info(msg, conn) do
    Logger.debug("Unhandled msg: #{inspect(msg)}")
    {:noreply, conn}
  end

  # Twitch Membership capability
  #     < CAP REQ :twitch.tv/membership
  #     > :tmi.twitch.tv CAP * ACK :twitch.tv/membership
  #
  # Twitch Tags capability
  #     < CAP REQ :twitch.tv/tags
  #     > :tmi.twitch.tv CAP * ACK :twitch.tv/tags
  #
  # Twitch Commands capability
  #     < CAP REQ :twitch.tv/commands
  #     > :tmi.twitch.tv CAP * ACK :twitch.tv/commands
  defp request_capabilities(client, cap) do
    cmd = ExIRC.Commands.command!('CAP REQ :twitch.tv/#{cap}')
    :ok = ExIRC.Client.cmd(client, cmd)
  end
end
