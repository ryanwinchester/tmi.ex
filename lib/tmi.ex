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

      def join(channel) do
        TMI.ChannelServer.join(__MODULE__, channel)
      end

      def kick(channel, user, message \\ "") do
        GenServer.cast(__MODULE__, {:kick, channel, user, message})
      end

      def me(channel, message) do
        GenServer.cast(__MODULE__, {:me, channel, message})
      end

      def part(channel) do
        TMI.ChannelServer.part(__MODULE__, channel)
      end

      def say(channel, message) do
        TMI.MessageServer.add_message(__MODULE__, channel, message)
      end

      def whisper(user, message) do
        GenServer.cast(__MODULE__, {:whisper, user, message})
      end

      def list_channels do
        TMI.ChannelServer.list_channels(__MODULE__)
      end

      @spec connected?() :: boolean()
      def connected? do
        GenServer.call(__MODULE__, :connected?)
      end

      @spec logged_in?() :: boolean()
      def logged_in? do
        GenServer.call(__MODULE__, :logged_in?)
      end

      ## GenServer callbacks

      @impl GenServer
      def init(conn) do
        TMI.Client.add_handler(conn, self())
        {:ok, conn}
      end

      @impl GenServer
      def handle_call(:connected?, _from, conn) do
        {:reply, TMI.Client.is_connected?(conn), conn}
      end

      def handle_call(:logged_in?, _from, conn) do
        case TMI.Client.is_logged_on?(conn) do
          {:error, :not_connected} ->
            {:reply, false, conn}

          logged_in ->
            {:reply, logged_in, conn}
        end
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

      def handle_cast({:whisper, to, message}, conn) do
        TMI.WhisperServer.add_whisper(__MODULE__, conn.user, to, message)
        {:noreply, conn}
      end

      @impl GenServer
      def handle_info(msg, conn) do
        TMI.apply_incoming_to_bot(msg, __MODULE__)
        {:noreply, conn}
      end

      ## Bot callbacks

      @impl TMI.Handler
      def handle_event(event) do
        Logger.debug("[#{__MODULE__}] #{inspect(event, pretty: true)}")
      end

      defoverridable handle_event: 1
    end
  end

  @doc """
  Parse Twitch tags, if they are enabled.

  ## Examples:

      iex> parse_tags("@badge-info=subscriber/25;badges=broadcaster/1,subscriber/0;color=#333333;display-name=JohnDoe")
      %{
        "@badge-info" => "subscriber/25",
        "badges" => "broadcaster/1,subscriber/0",
        "color" => "#333333",
        "display-name" => "JohnDoe"
      }

  """
  def parse_tags(tags) do
    tags
    |> String.split(";")
    |> Enum.map(&String.split(&1, "="))
    |> Enum.into(%{}, &List.to_tuple/1)
  end

  # ----------------------------------------------------------------------------
  # Convert the ExIRC message to bot message.
  # ----------------------------------------------------------------------------

  ## WITH tags

  @doc false
  # TODO: Add more cases.
  def apply_incoming_to_bot({:unrecognized, tags, %ExIRC.Message{args: [arg]}} = msg, bot) do
    cond do
      String.contains?(arg, "PRIVMSG") ->
        {message, sender, channel} = parse_message(arg)

        case message do
          <<0x01, "ACTION ", message::binary>> ->
            message = String.trim_trailing(message, <<0x01>>)
            apply(bot, :handle_action, [message, sender, channel, parse_tags(tags)])

          message ->
            apply(bot, :handle_message, [message, sender, channel, parse_tags(tags)])
        end

      String.contains?(arg, "WHISPER") ->
        {message, sender} = parse_whisper(arg)
        apply(bot, :handle_whisper, [message, sender, parse_tags(tags)])

      true ->
        apply(bot, :handle_unrecognized, [msg, parse_tags(tags)])
    end
  end

  ## Without tags

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
