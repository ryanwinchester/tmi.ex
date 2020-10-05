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

  defmacro __using__(opts \\ []) do
    command_prefix = Keyword.get(opts, :command_prefix, "!")

    quote do
      @behaviour TMI.Handler

      Module.register_attribute __MODULE__, :message_handlers, accumulate: true
      Module.register_attribute __MODULE__, :command_handlers, accumulate: true

      import unquote(__MODULE__)

      require Logger

      @command_prefix unquote(command_prefix)

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

      defoverridable(
        handle_connected: 2,
        handle_logged_in: 0,
        handle_login_failed: 1,
        handle_disconnected: 0,
        handle_join: 1,
        handle_join: 2,
        handle_part: 1,
        handle_part: 2,
        handle_kick: 2,
        handle_kick: 3,
        handle_whisper: 2,
        handle_message: 3,
        handle_mention: 3,
        handle_action: 3,
        handle_unrecognized: 1
      )
    end

    @before_compile unquote(__MODULE__)
  end

  defmacro __before_compile__(env) do
    message_handlers = Module.get_attribute(env.module, :message_handler)
    command_handlers = Module.get_attribute(env.module, :command_handler)
    command_prefix = Module.get_attribute(env.module, :command_prefix)

    quote do
      @impl true
      def handle_message(unquote(command_prefix) <> rest, sender, chat) do
        command = String.split(rest, " ", parts: 2) do
        for {regex, handler} <- @command_handlers do
          if Regex.match?(regex, Enum.at(command, 0)) do
            apply(__MODULE__, handler, [regex, command, sender, chat])
          end
        end
      end

      def handle_message(message, sender, chat) do
        for {regex, handler} <- @message_handlers do
          if Regex.match?(regex, Enum.at(command, 0)) do
            apply(__MODULE__, handler, [%{matches: get_matches(regex, message), message, sender, chat}])
          end
        end
      end
    end
  end

  defmacro message(regex, msg \\ Macro.escape(%{}), do: block) do
    func_name = unique_func_name("message_handler")
    quote do
      @message_handlers {unquote(regex), unquote(func_name)}
      def unquote(func_name)(message, sender, chat, unquote(state)) do
        unquote(block)
      end
    end
  end

  defmacro command(regex, msg \\ Macro.escape(%{}), do: block) do
    func_name = unique_func_name("command_handler")
    quote do
      @command_handlers {unquote(regex), unquote(func_name)}
      def unquote(func_name)(regex, [command], sender, chat) do
        unquote(block)
      end
      def unquote(func_name)(regex, [command, message], sender, chat) do
        unquote(block)
      end
    end
  end

  defp unique_func_name(type) do
    String.to_atom("#{type}_#{System.unique_integer([:positive, :monotonic])}")
  end

  defp get_matches(regex, message) do
    case Regex.names(regex) do
      [] ->
        matches = Regex.run(regex, text)
        Enum.reduce(Enum.with_index(matches), %{}, fn {match, index}, acc ->
          Map.put(acc, index, match)
        end)
      _ ->
        Regex.named_captures(regex, text)
    end
  end
end
