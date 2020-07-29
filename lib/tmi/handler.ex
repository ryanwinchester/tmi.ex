defmodule TMI.Handler do
  @moduledoc """
  Define a Handler behaviour and default implementations.
  """

  @callback handle_connected(server :: String.t(), port :: integer) :: any

  @callback handle_logged_in() :: any

  @callback handle_login_failed(reason :: atom) :: any

  @callback handle_disconnected() :: any

  @callback handle_join(chat :: String.t()) :: any

  @callback handle_join(chat :: String.t(), user :: String.t()) :: any

  @callback handle_part(chat :: String.t()) :: any

  @callback handle_part(chat :: String.t(), user :: String.t()) :: any

  @callback handle_kick(chat :: String.t(), kicker :: String.t()) :: any

  @callback handle_kick(chat :: String.t(), user :: String.t(), kicker :: String.t()) :: any

  @callback handle_whisper(message :: String.t(), sender :: String.t()) :: any

  @callback handle_message(message :: String.t(), sender :: String.t(), chat :: String.t()) :: any

  @callback handle_mention(message :: String.t(), sender :: String.t(), chat :: String.t()) :: any

  @callback handle_action(message :: String.t(), sender :: String.t(), chat :: String.t()) :: any

  @callback handle_unrecognized(msg :: any) :: any

  defmacro __using__(_) do
    quote do
      @behaviour TMI.Handler

      require Logger

      @impl true
      def handle_connected(server, port) do
        Logger.debug("[TMI] Connected to #{server} on #{port}")
      end

      @impl true
      def handle_logged_in() do
        Logger.debug("[TMI] Logged in")
      end

      @impl true
      def handle_login_failed(reason) do
        Logger.debug("[TMI] Login failed: #{reason}")
      end

      @impl true
      def handle_disconnected() do
        Logger.debug("[TMI] Disconnected")
      end

      @impl true
      def handle_join(chat) do
        Logger.debug("[TMI] [#{chat}] you joined")
      end

      @impl true
      def handle_join(chat, user) do
        Logger.debug("[TMI] [#{chat}] #{user} joined")
      end

      @impl true
      def handle_part(chat) do
        Logger.debug("[TMI] [#{chat}] you left")
      end

      @impl true
      def handle_part(chat, user) do
        Logger.debug("[TMI] [#{chat}] #{user} left")
      end

      @impl true
      def handle_kick(chat, kicker) do
        Logger.debug("[TMI] [#{chat}] You were kicked by #{kicker}")
      end

      @impl true
      def handle_kick(chat, user, kicker) do
        Logger.debug("[TMI] [#{chat}] #{user} was kicked by #{kicker}")
      end

      @impl true
      def handle_whisper(message, sender) do
        Logger.debug("[TMI] #{sender} WHISPERS: #{message}")
      end

      @impl true
      def handle_message(message, sender, chat) do
        Logger.debug("[TMI] [#{chat}] #{sender} SAYS: #{message}")
      end

      @impl true
      def handle_mention(message, sender, chat) do
        Logger.debug("[TMI] [#{chat}] MENTION - #{sender} SAYS: #{message}")
      end

      @impl true
      def handle_action(message, sender, chat) do
        Logger.debug("[TMI] [#{chat}] * #{sender} #{message}")
      end

      @impl true
      def handle_unrecognized(msg) do
        nil
      end

      defoverridable TMI.Handler
    end
  end
end
