defmodule TMI do
  @moduledoc false

  @doc false
  defmacro __using__(_) do
    quote do
      use GenServer

      require Logger

      @behaviour TMI.Handler

      @spec start_link(TMI.Conn.t()) :: GenServer.on_start()
      def start_link(conn) do
        GenServer.start_link(__MODULE__, conn, name: __MODULE__)
      end

      def kick(channel, user, message \\ "") do
        GenServer.cast(__MODULE__, {:kick, channel, user, message})
      end

      def me(channel, message) do
        GenServer.cast(__MODULE__, {:me, channel, message})
      end

      def part(channel) do
        GenServer.cast(__MODULE__, {:part, channel})
      end

      def say(channel, message) do
        TMI.MessageServer.add_message(__MODULE__, channel, message)
      end

      def whisper(user, message) do
        GenServer.cast(__MODULE__, {:whisper, user, message})
      end

      ## GenServer callbacks

      @impl GenServer
      def init(conn) do
        TMI.Client.add_handler(conn, self())
        {:ok, conn}
      end

      @impl GenServer
      def handle_cast({:kick, channel, user, message}, conn) do
        TMI.Client.kick(conn, channel, user, message)
        {:noreply, conn}
      end

      def handle_cast({:me, channel, message}, conn) do
        TMI.Client.me(conn, channel, message)
        {:noreply, conn}
      end

      def handle_cast({:part, channel}, conn) do
        TMI.Client.part(conn, channel)
        {:noreply, conn}
      end

      def handle_cast({:whisper, user, message}, conn) do
        TMI.Client.whisper(conn, user, message)
        {:noreply, conn}
      end

      @impl GenServer
      def handle_info(msg, conn) do
        TMI.apply_incoming_to_bot(msg, __MODULE__)
        {:noreply, conn}
      end

      ## Bot callbacks

      @impl TMI.Handler
      def handle_action(message, sender, channel) do
        Logger.debug("[#{__MODULE__}] [#{channel}] * #{sender} #{message}")
      end

      @impl TMI.Handler
      def handle_connected(server, port) do
        Logger.debug("[#{__MODULE__}] Connected to #{server} on #{port}")
      end

      @impl TMI.Handler
      def handle_disconnected() do
        Logger.debug("[#{__MODULE__}] Disconnected")
      end

      @impl TMI.Handler
      def handle_join(channel) do
        Logger.debug("[#{__MODULE__}] [#{channel}] you joined")
      end

      @impl TMI.Handler
      def handle_join(channel, user) do
        Logger.debug("[#{__MODULE__}] [#{channel}] #{user} joined")
      end

      @impl TMI.Handler
      def handle_kick(channel, kicker) do
        Logger.debug("[#{__MODULE__}] [#{channel}] You were kicked by #{kicker}")
      end

      @impl TMI.Handler
      def handle_kick(channel, user, kicker) do
        Logger.debug("[#{__MODULE__}] [#{channel}] #{user} was kicked by #{kicker}")
      end

      @impl TMI.Handler
      def handle_logged_in() do
        Logger.debug("[#{__MODULE__}] Logged in")
      end

      @impl TMI.Handler
      def handle_login_failed(reason) do
        Logger.debug("[#{__MODULE__}] Login failed: #{reason}")
      end

      @impl TMI.Handler
      def handle_mention(message, sender, channel) do
        Logger.debug("[#{__MODULE__}] [#{channel}] MENTION - #{sender} SAYS: #{message}")
      end

      @impl TMI.Handler
      def handle_message(message, sender, channel) do
        Logger.debug("[#{__MODULE__}] [#{channel}] #{sender} SAYS: #{message}")
      end

      @impl TMI.Handler
      def handle_part(channel) do
        Logger.debug("[#{__MODULE__}] [#{channel}] you left")
      end

      @impl TMI.Handler
      def handle_part(channel, user) do
        Logger.debug("[#{__MODULE__}] [#{channel}] #{user} left")
      end

      @impl TMI.Handler
      def handle_unrecognized(msg) do
        Logger.debug("[#{__MODULE__}] UNRECOGNIZED: #{inspect(msg)}")
      end

      @impl TMI.Handler
      def handle_whisper(message, sender) do
        Logger.debug("[#{__MODULE__}] #{sender} WHISPERS: #{message}")
      end

      defoverridable(
        handle_action: 3,
        handle_connected: 2,
        handle_disconnected: 0,
        handle_join: 1,
        handle_join: 2,
        handle_kick: 2,
        handle_kick: 3,
        handle_logged_in: 0,
        handle_login_failed: 1,
        handle_mention: 3,
        handle_message: 3,
        handle_part: 1,
        handle_part: 2,
        handle_unrecognized: 1,
        handle_whisper: 2
      )
    end
  end

  # Convert the ExIRC message to bot message.
  @doc false
  def apply_incoming_to_bot({:connected, server, port}, bot) do
    apply(bot, :handle_connected, [server, port])
  end

  def apply_incoming_to_bot(:logged_in, bot) do
    apply(bot, :handle_logged_in, [])
  end

  def apply_incoming_to_bot({:login_failed, reason}, bot) do
    apply(bot, :handle_login_failed, [reason])
  end

  def apply_incoming_to_bot(:disconnected, bot) do
    apply(bot, :handle_disconnected, [])
  end

  def apply_incoming_to_bot({:joined, channel}, bot) do
    apply(bot, :handle_join, [channel])
  end

  def apply_incoming_to_bot({:joined, channel, user}, bot) do
    apply(bot, :handle_join, [channel, user.user])
  end

  def apply_incoming_to_bot({:parted, channel, user}, bot) do
    apply(bot, :handle_part, [channel, user.user])
  end

  def apply_incoming_to_bot({:kicked, user, channel}, bot) do
    apply(bot, :handle_kick, [channel, user.user])
  end

  def apply_incoming_to_bot({:kicked, user, kicker, channel}, bot) do
    apply(bot, :handle_kick, [channel, user.user, kicker.user])
  end

  def apply_incoming_to_bot({:received, message, sender}, bot) do
    apply(bot, :handle_whisper, [message, sender.user])
  end

  def apply_incoming_to_bot({:received, message, sender, channel}, bot) do
    apply(bot, :handle_message, [message, sender.user, channel])
  end

  def apply_incoming_to_bot({:mentioned, message, sender, channel}, bot) do
    apply(bot, :handle_mention, [message, sender.user, channel])
  end

  def apply_incoming_to_bot({:me, message, sender, channel}, bot) do
    apply(bot, :handle_action, [message, sender.user, channel])
  end

  def apply_incoming_to_bot(msg, bot) do
    apply(bot, :handle_unrecognized, [msg])
  end
end
