defmodule TMI.Handlers.MessageHandler do
  @moduledoc false

  use GenServer

  require Logger

  alias TMI.Client
  alias TMI.Conn

  def start_link({%Conn{} = conn, handler}) do
    GenServer.start_link(__MODULE__, {conn, handler}, name: __MODULE__)
  end

  @impl true
  def init({conn, handler}) do
    Client.add_handler(conn, self())
    {:ok, handler}
  end

  @impl true
  def handle_info({:connected, server, port}, handler) do
    apply(handler, :handle_connected, [server, port])
    {:noreply, handler}
  end

  def handle_info(:logged_in, handler) do
    apply(handler, :handle_logged_in, [])
    {:noreply, handler}
  end

  def handle_info({:login_failed, reason}, handler) do
    apply(handler, :handle_login_failed, [reason])
    {:noreply, handler}
  end

  def handle_info(:disconnected, handler) do
    apply(handler, :handle_disconnected, [])
    {:noreply, handler}
  end

  def handle_info({:joined, channel}, handler) do
    apply(handler, :handle_join, [channel])
    {:noreply, handler}
  end

  def handle_info({:joined, channel, user}, handler) do
    apply(handler, :handle_join, [channel, user.user])
    {:noreply, handler}
  end

  def handle_info({:parted, channel, user}, handler) do
    apply(handler, :handle_part, [channel, user.user])
    {:noreply, handler}
  end

  def handle_info({:kicked, user, channel}, handler) do
    apply(handler, :handle_kick, [channel, user.user])
    {:noreply, handler}
  end

  def handle_info({:kicked, user, kicker, channel}, handler) do
    apply(handler, :handle_kick, [channel, user.user, kicker.user])
    {:noreply, handler}
  end

  def handle_info({:received, message, sender}, handler) do
    apply(handler, :handle_whisper, [message, sender.user])
    {:noreply, handler}
  end

  def handle_info({:received, message, sender, channel}, handler) do
    apply(handler, :handle_message, [message, sender.user, channel])
    {:noreply, handler}
  end

  def handle_info({:mentioned, message, sender, channel}, handler) do
    apply(handler, :handle_mention, [message, sender.user, channel])
    {:noreply, handler}
  end

  def handle_info({:me, message, sender, channel}, handler) do
    apply(handler, :handle_action, [message, sender.user, channel])
    {:noreply, handler}
  end

  def handle_info(msg, handler) do
    apply(handler, :handle_unrecognized, [msg])
    {:noreply, handler}
  end
end
