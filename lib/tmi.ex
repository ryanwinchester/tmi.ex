defmodule TMI do
  @moduledoc false

  require Logger

  @doc false
  defmacro __using__(_) do
    quote do
      use GenServer

      require Logger

      @behaviour TMI.Handler

      @spec start_link(TMI.IRC.Conn.t()) :: GenServer.on_start()
      def start_link(conn) do
        GenServer.start_link(__MODULE__, conn, name: __MODULE__)
      end

      def join(channel) do
        TMI.IRC.ChannelServer.join(__MODULE__, channel)
      end

      def part(channel) do
        TMI.IRC.ChannelServer.part(__MODULE__, channel)
      end

      def me(channel, message) do
        GenServer.cast(__MODULE__, {:me, channel, message})
      end

      def say(channel, message) do
        TMI.IRC.MessageServer.add_message(__MODULE__, channel, message)
      end

      def whisper(user, message) do
        GenServer.cast(__MODULE__, {:whisper, user, message})
      end

      def list_channels do
        TMI.IRC.ChannelServer.list_channels(__MODULE__)
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
        TMI.IRC.Client.add_handler(conn, self())
        {:ok, conn}
      end

      @impl GenServer
      def handle_call(:connected?, _from, conn) do
        {:reply, TMI.IRC.Client.is_connected?(conn), conn}
      end

      def handle_call(:logged_in?, _from, conn) do
        case TMI.IRC.Client.is_logged_on?(conn) do
          {:error, :not_connected} ->
            {:reply, false, conn}

          logged_in ->
            {:reply, logged_in, conn}
        end
      end

      @impl GenServer
      def handle_cast({:kick, channel, user, message}, conn) do
        TMI.IRC.Client.kick(conn, channel, user, message)
        {:noreply, conn}
      end

      def handle_cast({:me, channel, message}, conn) do
        TMI.IRC.Client.me(conn, channel, message)
        {:noreply, conn}
      end

      def handle_cast({:part, channel}, conn) do
        TMI.IRC.Client.part(conn, channel)
        {:noreply, conn}
      end

      def handle_cast({:whisper, to, message}, conn) do
        TMI.IRC.WhisperServer.add_whisper(__MODULE__, conn.user, to, message)
        {:noreply, conn}
      end

      @impl GenServer
      def handle_info(msg, conn) do
        TMI.apply_incoming_to_bot(msg, __MODULE__)
        {:noreply, conn}
      end

      ## Bot callbacks

      @impl TMI.Handler
      def handle_connected(server, port) do
        Logger.debug("[#{TMI.bot_string(__MODULE__)}] Connected to #{server} on #{port}")
      end

      @impl TMI.Handler
      def handle_disconnected() do
        Logger.debug("[#{TMI.bot_string(__MODULE__)}] Disconnected")
      end

      @impl TMI.Handler
      def handle_event(event) do
        TMI.default_handle_event(event, __MODULE__)
      end

      @before_compile {TMI, :add_handle_event_fallback}

      @impl TMI.Handler
      def handle_join(channel) do
        Logger.debug("[#{TMI.bot_string(__MODULE__)}] [#{channel}] you joined")
      end

      @impl TMI.Handler
      def handle_join(channel, user) do
        Logger.debug("[#{TMI.bot_string(__MODULE__)}] [#{channel}] #{user} joined")
      end

      @impl TMI.Handler
      def handle_kick(channel, kicker) do
        Logger.debug("[#{TMI.bot_string(__MODULE__)}] [#{channel}] You were kicked by #{kicker}")
      end

      @impl TMI.Handler
      def handle_kick(channel, user, kicker) do
        Logger.debug("[#{TMI.bot_string(__MODULE__)}] [#{channel}] #{user} was kicked by #{kicker}")
      end

      @impl TMI.Handler
      def handle_logged_in() do
        Logger.debug("[#{TMI.bot_string(__MODULE__)}] Logged in")
      end

      @impl TMI.Handler
      def handle_login_failed(reason) do
        Logger.debug("[#{TMI.bot_string(__MODULE__)}] Login failed: #{reason}")
      end

      @impl TMI.Handler
      def handle_mention(message, sender, channel) do
        Logger.debug("[#{TMI.bot_string(__MODULE__)}] [#{channel}] MENTION - <#{sender}> #{message}")
      end

      @impl TMI.Handler
      def handle_part(channel) do
        Logger.debug("[#{TMI.bot_string(__MODULE__)}] [#{channel}] you left")
      end

      @impl TMI.Handler
      def handle_part(channel, user) do
        Logger.debug("[#{TMI.bot_string(__MODULE__)}] [#{channel}] #{user} left")
      end

      @impl TMI.Handler
      def handle_unrecognized(_tags, msg) do
        Logger.debug("[#{TMI.bot_string(__MODULE__)}] UNRECOGNIZED: #{msg}")
      end

      @impl TMI.Handler
      def handle_unrecognized(msg) do
        Logger.debug("[#{TMI.bot_string(__MODULE__)}] UNRECOGNIZED: #{inspect(msg, pretty: true)}")
      end

      defoverridable(
        handle_connected: 2,
        handle_disconnected: 0,
        handle_event: 1,
        handle_join: 1,
        handle_join: 2,
        handle_kick: 2,
        handle_kick: 3,
        handle_logged_in: 0,
        handle_login_failed: 1,
        handle_mention: 3,
        handle_part: 1,
        handle_part: 2,
        handle_unrecognized: 1,
        handle_unrecognized: 2
      )
    end
  end

  @doc false
  defmacro add_handle_event_fallback(_env) do
    quote do
      def handle_event(event) do
        TMI.default_handle_event(event, __MODULE__)
      end
    end
  end

  @doc false
  def default_handle_event(%TMI.Events.Message{} = event, module) do
    Logger.debug("[#{bot_string(module)}] [#{event.channel}] <#{event.user_login}> #{event.message}")
  end

  def default_handle_event(%TMI.Events.ChatAction{} = event, module) do
    Logger.debug("[#{bot_string(module)}] [#{event.channel}] * <#{event.user_id}> #{event.message}")
  end

  def default_handle_event(%TMI.Events.Whisper{} = event, module) do
    Logger.debug("[#{bot_string(module)}] WHISPER - <#{event.user_login}> #{event.message}")
  end

  def default_handle_event(event, module) do
    Logger.debug("[#{bot_string(module)}] EVENT\n#{inspect(event, pretty: true)}")
  end

  @doc """
  Takes a module and returns the string version without the `Elixir` prepended
  to the front. Makes it nicer to read in log messages.

  ## Example

      iex> TMI.bot_string(Foo.Bar.Bot)
      "Foo.Bar.Bot"

  """
  def bot_string(module) do
    module
    |> to_string()
    |> String.split(".")
    |> List.delete_at(0)
    |> Enum.join(".")
  end

  @doc """
  Parse a PRIVMSG message.

  ## Example

      iex> message_args_to_map("shyryan!johndoe@johndoe.tmi.twitch.tv PRIVMSG #shyryan :Hello World")
      %{message: "Hello World", user_login: "shyryan", channel: "#shyryan"}

  """
  def message_args_to_map(message) do
    [full_sender, channel_message] = :binary.split(message, " PRIVMSG ")
    [channel, message] = :binary.split(channel_message, " :")
    [sender, _] = :binary.split(full_sender, "!")
    %{channel: channel, message: message, user_login: sender}
  end

  @doc """
  Parse a WHISPER message.

  ## Example:

      iex> whisper_args_to_map("johndoe!johndoe@johndoe.tmi.twitch.tv WHISPER janedoe :Hello World")
      %{message: "Hello World", user_login: "johndoe"}

  """
  def whisper_args_to_map(message) do
    [full_sender, recipient_message] = :binary.split(message, " WHISPER ")
    [_recipient, message] = :binary.split(recipient_message, " :")
    [sender, _] = :binary.split(full_sender, "!")
    %{message: message, user_login: sender}
  end

  @doc """
  Parse a USERNOTICE message.

  ## Example:

      iex> usernotice_args_to_map("tmi.twitch.tv USERNOTICE #ryanwinchester_")
      %{channel: "#ryanwinchester_"}

  """
  def usernotice_args_to_map(message) do
    [_server, channel] = :binary.split(message, " USERNOTICE ")
    %{channel: channel}
  end

  @doc """
  Parse a NOTICE message.

  ## Example:

      iex> args = "tmi.twitch.tv NOTICE #ryanwinchester_ :This room is no longer in emote-only mode."
      iex> notice_args_to_map(args)
      %{channel: "#ryanwinchester_"}

  """
  def notice_args_to_map(message) do
    [_server, notice] = :binary.split(message, " NOTICE ")
    [channel, _rest] = :binary.split(notice, " :")
    %{channel: channel}
  end

  @doc """
  Parse a ROOMSTATE message.

  ## Example:

      iex> roomstate_args_to_map("tmi.twitch.tv ROOMSTATE #ryanwinchester_")
      %{channel: "#ryanwinchester_"}

  """
  def roomstate_args_to_map(message) do
    [_server, channel] = :binary.split(message, " ROOMSTATE ")
    %{channel: channel}
  end

  @doc """
  Parse Twitch tags, if they are enabled.

  ## Examples:

      iex> parse_tags("@badge-info=subscriber/25;badges=broadcaster/1,subscriber/0;color=#333333;display-name=JohnDoe")
      %{
        badge_info: [{"subscriber", 25}],
        badges: [{"broadcaster", 1}, {"subscriber", 0}],
        color: "#333333",
        display_name: "JohnDoe"
      }

  """
  def parse_tags(tag_string), do: TMI.IRC.Tags.parse!(tag_string)

  # ----------------------------------------------------------------------------
  # Convert the ExIRC message to bot message.
  # ----------------------------------------------------------------------------

  # TODO: I think I will want to recursively parse the message args until I get
  # one of the `PRIVMSG`, `USERNOTICE`, etc. messages.
  # As it is now, if we get a message or system_msg or anything that has this
  # text, we could get unexpected results since `String.contains?/2` could match.
  def parse_message({:unrecognized, tag_string, %ExIRC.Message{args: [arg]} = msg}) do
    cond do
      String.contains?(arg, "PRIVMSG") ->
        case message_args_to_map(arg) do
          %{message: <<0x01, "ACTION ", message::binary>>} = params ->
            tag_string
            |> TMI.IRC.Tags.parse!()
            |> TMI.Event.from_map_with_name(:chat_action, %{
              params
              | message: String.trim_trailing(message, <<0x01>>)
            })

          params ->
            tag_string
            |> TMI.IRC.Tags.parse!()
            |> TMI.Event.from_map_with_name(:message, params)
        end

      String.contains?(arg, "USERNOTICE") ->
        tag_string
        |> TMI.IRC.Tags.parse!()
        |> TMI.Event.from_map(usernotice_args_to_map(arg))

      String.contains?(arg, "NOTICE") ->
        tag_string
        |> TMI.IRC.Tags.parse!()
        |> TMI.Event.from_map(notice_args_to_map(arg))

      String.contains?(arg, "ROOMSTATE") ->
        tag_string
        |> TMI.IRC.Tags.parse!()
        |> TMI.Event.from_map_with_name(:channel_update, roomstate_args_to_map(arg))

      String.contains?(arg, "WHISPER") ->
        tag_string
        |> TMI.IRC.Tags.parse!()
        |> TMI.Event.from_map_with_name(:whisper, whisper_args_to_map(arg))

      true ->
        tag_string
        |> TMI.IRC.Tags.parse!()
        |> TMI.Event.from_map_with_name(:unrecognized, %{msg: msg})
    end
  end

  def parse_message({:unrecognized, _cmd, %ExIRC.Message{} = msg}) do
    TMI.Event.from_map_with_name(%{}, :unrecognized, %{msg: msg})
  end

  ## WITH tags

  @doc false
  def apply_incoming_to_bot({:unrecognized, _tag_string, %ExIRC.Message{}} = msg, bot) do
    parse_message(msg) |> bot.handle_event()
  end

  ## Without tags

  def apply_incoming_to_bot({:connected, server, port}, bot) do
    bot.handle_connected(server, port)
  end

  def apply_incoming_to_bot(:logged_in, bot) do
    bot.handle_logged_in()
  end

  def apply_incoming_to_bot({:login_failed, reason}, bot) do
    bot.handle_login_failed(reason)
  end

  def apply_incoming_to_bot(:disconnected, bot) do
    bot.handle_disconnected()
  end

  def apply_incoming_to_bot({:joined, channel}, bot) do
    bot.handle_join(channel)
  end

  def apply_incoming_to_bot({:joined, channel, user}, bot) do
    bot.handle_join(channel, user.user)
  end

  def apply_incoming_to_bot({:parted, channel, user}, bot) do
    bot.handle_part(channel, user.user)
  end

  def apply_incoming_to_bot({:kicked, user, channel}, bot) do
    bot.handle_kick(channel, user.user)
  end

  def apply_incoming_to_bot({:kicked, user, kicker, channel}, bot) do
    bot.handle_kick(channel, user.user, kicker.user)
  end

  def apply_incoming_to_bot({:received, message, sender}, bot) do
    bot.handle_whisper(message, sender.user)
  end

  def apply_incoming_to_bot({:received, message, sender, channel}, bot) do
    bot.handle_message(message, sender.user, channel)
  end

  def apply_incoming_to_bot({:mentioned, message, sender, channel}, bot) do
    bot.handle_mention(message, sender.user, channel)
  end

  def apply_incoming_to_bot({:me, message, sender, channel}, bot) do
    bot.handle_action(message, sender.user, channel)
  end

  def apply_incoming_to_bot(msg, bot) do
    bot.handle_unrecognized(msg)
  end
end
