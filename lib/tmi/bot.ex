defmodule TMI.Bot do
  @moduledoc """
  Define a Handler behaviour and default implementations.
  """

  @callback handle_action(message :: String.t(), sender :: String.t(), channel :: String.t()) ::
              any

  @callback handle_connected(server :: String.t(), port :: integer) :: any

  @callback handle_disconnected() :: any

  @callback handle_join(channel :: String.t()) :: any

  @callback handle_join(channel :: String.t(), user :: String.t()) :: any

  @callback handle_kick(channel :: String.t(), kicker :: String.t()) :: any

  @callback handle_kick(channel :: String.t(), user :: String.t(), kicker :: String.t()) :: any

  @callback handle_logged_in() :: any

  @callback handle_login_failed(reason :: atom) :: any

  @callback handle_message(message :: String.t(), sender :: String.t(), channel :: String.t()) ::
              any

  @callback handle_mention(message :: String.t(), sender :: String.t(), channel :: String.t()) ::
              any

  @callback handle_part(channel :: String.t()) :: any

  @callback handle_part(channel :: String.t(), user :: String.t()) :: any

  @callback handle_unrecognized(msg :: any) :: any

  @callback handle_whisper(message :: String.t(), sender :: String.t()) :: any

  @doc false
  defmacro __using__(_) do
    quote do
      use GenServer

      require Logger

      @behaviour TMI.Bot

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
        apply(TMI.MessageServer.module_name(__MODULE__, channel), :add_message, [message])
      end

      def whisper(user, message) do
        GenServer.cast(__MODULE__, {:whisper, channel, message})
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
        TMI.Client.say(conn, channel)
        {:noreply, conn}
      end

      def handle_cast({:whisper, user, message}, conn) do
        TMI.Client.whisper(conn, user, message)
        {:noreply, conn}
      end

      @impl GenServer
      def handle_info(msg, conn) do
        TMI.MessageHandler.handle_message(msg, __MODULE__, conn)
        {:noreply, conn}
      end

      ## Bot callbacks

      @impl TMI.Bot
      def handle_action(message, sender, channel) do
        Logger.debug("[#{__MODULE__}] [#{channel}] * #{sender} #{message}")
      end

      @impl TMI.Bot
      def handle_connected(server, port) do
        Logger.debug("[#{__MODULE__}] Connected to #{server} on #{port}")
      end

      @impl TMI.Bot
      def handle_disconnected() do
        Logger.debug("[#{__MODULE__}] Disconnected")
      end

      @impl TMI.Bot
      def handle_join(channel) do
        Logger.debug("[#{__MODULE__}] [#{channel}] you joined")
      end

      @impl TMI.Bot
      def handle_join(channel, user) do
        Logger.debug("[#{__MODULE__}] [#{channel}] #{user} joined")
      end

      @impl TMI.Bot
      def handle_kick(channel, kicker) do
        Logger.debug("[#{__MODULE__}] [#{channel}] You were kicked by #{kicker}")
      end

      @impl TMI.Bot
      def handle_kick(channel, user, kicker) do
        Logger.debug("[#{__MODULE__}] [#{channel}] #{user} was kicked by #{kicker}")
      end

      @impl TMI.Bot
      def handle_logged_in() do
        Logger.debug("[#{__MODULE__}] Logged in")
      end

      @impl TMI.Bot
      def handle_login_failed(reason) do
        Logger.debug("[#{__MODULE__}] Login failed: #{reason}")
      end

      @impl TMI.Bot
      def handle_mention(message, sender, channel) do
        Logger.debug("[#{__MODULE__}] [#{channel}] MENTION - #{sender} SAYS: #{message}")
      end

      @impl TMI.Bot
      def handle_message(message, sender, channel) do
        Logger.debug("[#{__MODULE__}] [#{channel}] #{sender} SAYS: #{message}")
      end

      @impl TMI.Bot
      def handle_part(channel) do
        Logger.debug("[#{__MODULE__}] [#{channel}] you left")
      end

      @impl TMI.Bot
      def handle_part(channel, user) do
        Logger.debug("[#{__MODULE__}] [#{channel}] #{user} left")
      end

      @impl TMI.Bot
      def handle_unrecognized(msg) do
        Logger.debug("[#{__MODULE__}] UNRECOGNIZED: #{inspect(msg)}")
      end

      @impl TMI.Bot
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
end
