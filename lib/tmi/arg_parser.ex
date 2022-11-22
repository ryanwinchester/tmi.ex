defmodule TMI.ArgParser do
  @moduledoc """
  Parse `args` and `tags` into `TMI` events.
  """

  require Logger

  @doc """
  Parse the args into an event struct.
  """
  @spec to_event(String.t(), map()) :: struct()
  def to_event(args, tags)

  # CLEARCHAT
  # Sent when a moderator (or bot with moderator privileges) removes all
  # messages from the chat room or removes all messages for the specified user.
  # See: https://dev.twitch.tv/docs/irc/commands#clearchat
  def to_event("tmi.twitch.tv CLEARCHAT " <> rest, tags) do
    case String.split(rest, " ", parts: 2) do
      [channel] ->
        %TMI.Events.Clearchat{channel: channel}

      [channel, user] ->
        case tags do
          %{"@ban-duration" => duration} ->
            %TMI.Events.Timeout{
              channel: channel,
              duration: String.to_integer(duration),
              user: user,
              user_id: Map.get(tags, "target-user-id"),
              room_id: Map.get(tags, "room-id")
            }

          _ ->
            %TMI.Events.Ban{
              channel: channel,
              user: user,
              user_id: Map.get(tags, "target-user-id"),
              room_id: Map.get(tags, "room-id")
            }
        end
    end
  end

  # CLEARMSG
  # Sent when a bot with moderator privileges deletes a single message from the
  # chat room.
  # See: https://dev.twitch.tv/docs/irc/commands#clearmsg
  def to_event("tmi.twitch.tv CLEARMSG " <> rest, tags) do
    [channel, msg] = String.split(rest, " ", parts: 2)

    %TMI.Events.Messagedeleted{
      channel: channel,
      user: Map.get(tags, "@login"),
      message: msg,
      message_id: Map.get(tags, "target-msg-id")
    }
  end

  # GLOBALUSERSTATE
  # See: https://dev.twitch.tv/docs/irc/commands#globaluserstate
  # Sent after the bot successfully authenticates (by sending the PASS/NICK
  # commands) with the server.
  def to_event("tmi.twitch.tv GLOBALUSERSTATE", _tags) do
    # TODO: Handle maintaining a state for the bot user.
    # Has emote-sets, and stuff.
    %TMI.Events.Noop{}
  end

  # NOTICE
  # See: https://dev.twitch.tv/docs/irc/commands#notice
  #
  # Sent to indicate the outcome of an action like banning a user.
  #
  # The Twitch IRC server sends this message when:
  #
  #  * A moderator (or bot with moderator privileges) sends a message with
  #    pretty much any of the chat commands. For example, /emoteonly, /
  #    subscribers, /ban or /host.
  #
  def to_event("tmi.twitch.tv NOTICE " <> rest, tags) do
    [channel, msg] = String.split(rest, " ", parts: 2)
    notice_type = Map.fetch!(tags, "msg-id") |> String.to_existing_atom()

    if notice_type in TMI.Events.Notice.ignored_types() do
      %TMI.Events.Noop{}
    else
      %TMI.Events.Notice{
        channel: channel,
        message: msg,
        type: notice_type
      }
    end
  end

  # USERNOTICE
  # See: https://dev.twitch.tv/docs/irc/commands#usernotice
  #
  # Sent when events like someone subscribing to the channel occurs.
  #
  # The Twitch IRC server sends this message when:
  #
  #  * A user subscribes to the channel, re-subscribes to the channel, or gifts
  #    a subscription to another user.
  #  * Another broadcaster raids the channel. Raid is a Twitch feature that lets
  #    broadcasters send their viewers to another channel to help support and
  #    grow other members in the community.
  #  * A viewer milestone is celebrated such as a new viewer chatting for the
  #    first time.
  #
  def to_event("tmi.twitch.tv USERNOTICE " <> rest, tags) do
    [channel, msg] = String.split(rest, " ", parts: 2)
    user = Map.get(tags, "msg-param-displayName") || Map.get(tags, "msg-param-login")

    recipient =
      Map.get(tags, "msg-param-recipient-display-name") ||
        Map.get(tags, "msg-param-recipient-user-name")

    plan = Map.get(tags, "'msg-param-sub-plan")
    plan_name = Map.get(tags, "'msg-param-sub-plan-name")
    streak_months = get_integer_tag(tags, "msg-param-streak-months")
    gift_sub_count = get_integer_tag(tags, "msg-param-mass-gift-count")

    case Map.fetch!(tags, "msg-id") do
      "announcement" ->
        %TMI.Events.Announcement{
          channel: channel,
          user: user,
          message: msg,
          color: Map.get(tags, "msg-param-color"),
          tags: tags
        }

      "anongiftpaidupgrade" ->
        %TMI.Events.Anongiftpaidupgrade{
          channel: channel,
          user: user,
          tags: tags
        }

      "anonsubgift" ->
        %TMI.Events.Anonsubgift{
          channel: channel,
          streak_months: streak_months,
          recipient: recipient,
          plan: plan,
          plan_name: plan_name,
          tags: tags
        }

      "anonsubmysterygift" ->
        %TMI.Events.Anonsubmysterygift{
          channel: channel,
          gift_sub_count: gift_sub_count,
          plan: plan,
          plan_name: plan_name,
          tags: tags
        }

      "giftpaidupgrade" ->
        sender = Map.get(tags, "msg-param-sender-name") || Map.get(tags, "msg-param-sender-login")

        %TMI.Events.Giftpaidupgrade{
          channel: channel,
          streak_months: streak_months,
          user: user,
          sender: sender,
          tags: tags
        }

      "primepaidupgrade" ->
        %TMI.Events.Primepaidupgrade{
          channel: channel,
          user: user,
          plan: plan,
          plan_name: plan_name,
          tags: tags
        }

      "raid" ->
        %TMI.Events.Raided{
          channel: channel,
          user: user,
          viewer_count: get_integer_tag(tags, "msg-param-viewerCount"),
          tags: tags
        }

      "resub" ->
        %TMI.Events.Resub{
          channel: channel,
          user: user,
          streak_months: streak_months,
          total_months: total_months,
          message: msg,
          plan: plan,
          plan_name: plan_name,
          streak_months: streak_months,
          tags: tags
        }

      "ritual" ->
        %TMI.Event.Ritual{
          channel: channel,
          user: user,
          type: Map.get(tags, "msg-param-ritual-name"),
          message: msg,
          tags: tags
        }

      "sub" ->
        %TMI.Events.Subscription{
          channel: channel,
          user: user,
          total_months: total_months,
          message: msg,
          plan: plan,
          plan_name: plan_name,
          tags: tags
        }

      "subgift" ->
        %TMI.Events.Subgift{
          channel: channel,
          user: user,
          streak_months: streak_months,
          total_months: get_integer_tag(tags, "msg-param-months"),
          gift_months: get_integer_tag(tags, "msg-param-gift-months"),
          recipient: recipient,
          plan: plan,
          plan_name: plan_name,
          tags: tags
        }

      "submysterygift" ->
        %TMI.Events.Submysterygift{
          channel: channel,
          user: user,
          gift_sub_count: gift_sub_count,
          plan: plan,
          plan_name: plan_name,
          tags: tags
        }

      usernotice ->
        Logger.warn("[TMI] unhandled USERNOTICE #{usernotice}")
        %TMI.Events.Noop{}
    end
  end

  def to_event(args, tags) do
    cond do
      String.contains?(arg, "PRIVMSG") ->
        {message, sender, channel} = parse_message(arg)

        case message do
          <<0x01, "ACTION ", message::binary>> ->
            %TMI.Events.Action{
              channel: channel,
              user: sender,
              message: String.trim_trailing(message, <<0x01>>),
              tags: tags
            }

          message ->
            %TMI.Events.Message{
              channel: channel,
              user: sender,
              message: message
            }
        end

      String.contains?(arg, "WHISPER") ->
        {message, sender} = parse_whisper(arg)

        %TMI.Events.Whisper{
          user: sender,
          message: message,
          tags: tags
        }

      true ->
        Logger.warn("[TMI] unhandled PRIVMSG: #{args}")
        %TMI.Events.Noop{}
    end
  end

  # ----------------------------------------------------------------------------
  # Helpers
  # ----------------------------------------------------------------------------

  # Parse a PRIVMSG message.
  #
  # ## Example:
  #
  #     iex> parse_message("shyryan!shyryan@shyryan.tmi.twitch.tv PRIVMSG #shyryan :Hello World")
  #     {"Hello World", "shyryan", "#shyryan"}
  #
  @spec parse_message(String.t()) :: {String.t(), String.t(), String.t()}
  defp parse_message(message) do
    [full_sender, channel_message] = String.split(message, " PRIVMSG ", parts: 2)
    [channel, message] = String.split(channel_message, " :", parts: 2)
    [sender, _] = String.split(full_sender, "!", parts: 2)
    {message, sender, channel}
  end

  # Parse a WHISPER message.
  #
  # ## Example:
  #
  #     iex> parse_whisper("johndoe!johndoe@johndoe.tmi.twitch.tv WHISPER janedoe :Hello World")
  #     {"Hello World", "johndoe"}
  #
  @spec parse_whisper(String.t()) :: {String.t(), String.t()}
  defp parse_whisper(message) do
    [full_sender, recipient_message] = String.split(message, " WHISPER ", parts: 2)
    [_recipient, message] = String.split(recipient_message, " :", parts: 2)
    [sender, _] = String.split(full_sender, "!", parts: 2)
    {message, sender}
  end

  @spec get_integer_tag(map(), String.t()) :: integer()
  defp get_integer_tag(tags, key) do
    Map.get(tags, key, "0") |> String.to_integer()
  end
end
