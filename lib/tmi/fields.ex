defmodule TMI.Fields do
  @moduledoc """
  Fields derived from Twitch IRC tags.
  """

  @typedoc """
  Twitch tag `badge-info`.
  Contains metadata related to the chat badges in the badges tag. Currently,
  this tag contains metadata only for subscriber badges, to indicate the number
  of months the user has been a subscriber.
  """
  @type badge_info :: [{String.t(), non_neg_integer()}]

  @typedoc """
  Twitch tag `badges`.
  List of chat badges in the form, {badge, version}. For
  example, `{:admin, 1}`.

  There are many possible badge values, but here are few:
   * admin
   * bits
   * broadcaster
   * moderator
   * subscriber
   * staff
   * turbo

  Most badges have only 1 version, but some badges like subscriber badges offer
  different versions of the badge depending on how long the user has
  subscribed.

  To get the badge, use the Get Global Chat Badges and Get Channel Chat Badges
  APIs. Match the badge to the set-id field’s value in the response. Then,
  match the version to the id field in the list of versions.
  """
  @type badges :: [{String.t(), non_neg_integer()}]

  @typedoc """
  Twitch tag `ban-duration`.
  The message includes this tag if the user was put in a timeout. The tag
  contains the duration of the timeout, in seconds.
  """
  @type ban_duration :: non_neg_integer()

  @typedoc """
  Twitch tag `bits`.
  The amount of Bits the user cheered. Only a Bits cheer message includes this
  tag. To learn more about Bits, see the Extensions Monetization Guide. To get
  the cheermote, use the Get Cheermotes API. Match the cheer amount to the id
  field’s value in the response. Then, get the cheermote’s URL based on the
  cheermote theme, type, and size you want to use.
  """
  @type bits :: pos_integer()

  @typedoc """
  Twitch tag `color`.
  The color of the user’s name in the chat room. This is a hexadecimal RGB color
  code in the form, #<RGB>. This tag may be empty if it is never set.
  """
  @type color :: String.t() | nil

  @typedoc """
  Twitch tags `display-name` and `msg-param-displayName`.
  The user’s display name, escaped as described in the IRCv3 spec. This tag may
  be empty if it is never set.
  """
  @type display_name :: String.t() | nil

  @typedoc """
  Twitch tag `emotes`.
  A list of emotes and their positions in the message. Each emote is in the
  form, {<emote ID>, <start position>, <end position>}. The position indices are
  zero-based.

  To get the actual emote, see the Get Channel Emotes and Get Global Emotes
  APIs. For information about how to use the information that the APIs return,
  see Twitch emotes.

  NOTE It’s possible for the emotes flag’s value to be set to an action instead
  of identifying an emote. For example, `\\001ACTION barfs on the floor.\\001`.
  """
  @type emotes :: [{String.t(), non_neg_integer(), non_neg_integer()}]

  @typedoc """
  Twitch tag `emote-only`.
  A Boolean value that determines whether the chat room allows only messages
  with emotes. Is `true` if only emotes are allowed; otherwise, `false`.
  """
  @type emote_only? :: boolean()

  @typedoc """
  Twitch tag `emote-sets`.
  A list of IDs that identify the emote sets that the user has access to. Is
  always set to at least zero (0). To access the emotes in the set, use the Get
  Emote Sets API.
  """
  @type emote_sets :: [String.t()]

  @typedoc """
  Twitch tag `followers-only`.
  An integer value that determines whether only followers can post messages in
  the chat room. The value indicates how long, in minutes, the user must have
  followed the broadcaster before posting chat messages. If the value is -1, the
  chat room is not restricted to followers only.
  """
  @type followers_only :: -1 | non_neg_integer()

  @typedoc """
  Twitch tag `flags`.
  I don't know what this is yet.
  """
  @type flags :: term()

  @typedoc """
  Twitch tag `id`.
  An ID that uniquely identifies the message.
  """
  @type id :: String.t()

  @typedoc """
  Twitch tags `login` and `msg-param-login`.
  The name of the user who sent the message.
  """
  @type user_name :: String.t()

  @typedoc """
  Twitch tag `message-id`.
  An ID that uniquely identifies the whisper message.
  """
  @type message_id :: String.t()

  @typedoc """
  Twitch tag `mod`.
  A Boolean value that determines whether the user is a moderator. Is `true` if
  the user is a moderator; otherwise, `false`.
  """
  @type mod? :: boolean()

  @typedoc """
  Twitch tag `msg-id`.
  An ID that you can use to programmatically determine the action’s outcome. For
  a list of possible IDs, see `NOTICE` Message IDs.
  """
  @type event_id :: String.t()

  @typedoc """
  Twitch tag `msg-param-community-gift-id`.
  Not documented on Twitch.
  """
  @type community_gift_id :: String.t()

  @typedoc """
  Twitch tags `msg-param-months` and `msg-param-cumulative-months`.
  The total number of months the user has subscribed.
  """
  @type cumulative_months :: non_neg_integer()

  @typedoc """
  Twitch tag `msg-param-gift-months`.
  Included only with `subgift` notices.
  The number of months gifted as part of a single, multi-month gift.
  """
  @type gift_months :: non_neg_integer()

  @typedoc """
  Twitch tag `msg-param-mass-gift-count`.
  Not documented on Twitch. The number of subs in a community `submysterygift`.
  """
  @type count :: non_neg_integer()

  @typedoc """
  Twitch tag `msg-param-origin-id`.
  Not documented on Twitch.
  """
  @type origin_id :: String.t()

  @typedoc """
  Twitch tag `msg-param-promo-gift-total`.
  Included only with `anongiftpaidupgrade` and `giftpaidupgrade` notices.
  The number of gifts the gifter has given during the promo indicated by
  `msg-param-promo-name`.
  """
  @type promo_gift_total :: non_neg_integer()

  @typedoc """
  Twitch tag `msg-param-promo-name`.
  Included only with `anongiftpaidupgrade` and `giftpaidupgrade` notices.
  The subscriptions promo, if any, that is ongoing (for example,
  `Subtember 2018`).
  """
  @type promo_name :: String.t()

  @typedoc """
  Twitch tag `msg-param-recipient-display-name`.
  Included only with `subgift` notices.
  The display name of the subscription gift recipient.
  """
  @type recipient_display_name :: String.t()

  @typedoc """
  Twitch tag `msg-param-recipient-id`.
  Included only with `subgift` notices.
  The user ID of the subscription gift recipient.
  """
  @type recipient_id :: String.t()

  @typedoc """
  Twitch tag `msg-param-recipient-user-name`.
  Included only with `subgift` notices.
  The user name of the subscription gift recipient.
  """
  @type recipient_user_name :: String.t()

  @typedoc """
  Twitch tag `msg-param-ritual-name`.
  Included only with `ritual` notices.
  The name of the ritual being celebrated. For example: `new_chatter`.
  """
  @type ritual_name :: String.t()

  @typedoc """
  Twitch tag `msg-param-sender-count`.
  """
  @type sender_count :: non_neg_integer()

  @typedoc """
  Twitch tag `msg-param-sender-login`.
  Included only with `giftpaidupgrade` notices.
  The login name of the user who gifted the subscription.
  """
  @type sender_user_name :: String.t()

  @typedoc """
  Twitch tag `msg-param-sender-name`.
  Include only with `giftpaidupgrade` notices.
  The display name of the user who gifted the subscription.
  """
  @type sender_display_name :: String.t()

  @typedoc """
  Twitch tag `msg-param-should-share-streak`.
  Included only with `sub` and `resub` notices.
  A Boolean value that indicates whether the user wants their streaks shared.
  """
  @type share_streak? :: boolean()

  @typedoc """
  Twitch tag `msg-param-streak-months`.
  Included only with `sub` and `resub` notices.
  The number of consecutive months the user has subscribed. This is `0` if
  `msg-param-should-share-streak` is `0`.
  """
  @type streak_months :: non_neg_integer()

  @typedoc """
  Twitch tag `msg-param-sub-plan`.
  Included only with `sub`, `resub` and `subgift` notices.
  The type of subscription plan being used.
  """
  @type plan :: :prime | :t1 | :t2 | :t3

  @typedoc """
  Twitch tag `msg-param-sub-plan-name`.
  Included only with `sub`, `resub`, and `subgift` notices.
  The display name of the subscription plan. This may be a default name or one
  created by the channel owner.
  """
  @type plan_name :: String.t()

  @typedoc """
  Twitch tag `msg-param-threshold`.
  Included only with `bitsbadgetier` notices.
  The tier of the Bits badge the user just earned. For example, `100`, `1000`,
  or `10_000`.
  """
  @type bits_badge_tier :: non_neg_integer()

  @typedoc """
  Twitch tag `msg-param-viewerCount`.
  Included only with `raid` notices.
  The number of viewers raiding this channel from the broadcaster’s channel.
  """
  @type viewer_count :: non_neg_integer()

  @typedoc """
  Twitch tag `pinned-chat-paid-amount`.
  The value of the Hype Chat sent by the user.
  """
  @type amount :: number()

  @typedoc """
  Twitch tag `pinned-chat-paid-currency`.
  The ISO 4217 alphabetic currency code the user has sent the Hype Chat in.
  """
  @type currency :: String.t()

  @typedoc """
  Twitch tag `pinned-chat-paid-exponent`.
  Indicates how many decimal points this currency represents partial amounts in.
  Decimal points start from the right side of the value defined in
  `pinned-chat-paid-amount`.
  """
  @type exponent :: non_neg_integer()

  @typedoc """
  Twitch tag `pinned-chat-paid-is-system-message`.

  A Boolean value that determines if the message sent with the Hype Chat was
  filled in by the system.

  If `true`, the user entered no message and the body message was automatically
  filled in by the system. If `false`, the user provided their own message to
  send with the Hype Chat.
  """
  @type system_message? :: boolean()

  @typedoc """
  Twitch tag `pinned-chat-paid-level`.
  The level of the Hype Chat, in English. Possible values are:
   * ONE
   * TWO
   * THREE
   * FOUR
   * FIVE
   * SIX
   * SEVEN
   * EIGHT
   * NINE
   * TEN
  """
  @type level :: String.t()

  @typedoc """
  Twitch tag `r9k`.
  A Boolean value that determines whether a user’s messages must be unique.
  Applies only to messages with more than 9 characters. Is `true` if users must
  post unique messages; otherwise, `false`.
  """
  @type r9k? :: boolean()

  @typedoc """
  Twitch tag `reply-parent-display-name`.
  The display name of the sender of the direct parent message. The message does
  not include this tag if this message is not a reply.
  """
  @type parent_display_name :: String.t()

  @typedoc """
  Twitch tag `reply-parent-msg-body`.
  The text of the direct parent message. The message does not include this tag
  if this message is not a reply.
  """
  @type parent_message :: String.t()

  @typedoc """
  Twitch tag `reply-parent-msg-id`.
  An ID that uniquely identifies the direct parent message that this message is
  replying to. The message does not include this tag if this message is not a
  reply.
  """
  @type parent_id :: String.t()

  @typedoc """
  Twitch tag `reply-parent-user-id`.
  An ID that identifies the sender of the direct parent message. The message
  does not include this tag if this message is not a reply.
  """
  @type parent_user_id :: String.t()

  @typedoc """
  Twitch tag `reply-parent-user-login`.
  The login name of the sender of the direct parent message. The message does
  not include this tag if this message is not a reply.
  """
  @type parent_user_name :: String.t()

  @typedoc """
  Twitch tag `reply-thread-parent-msg-id`.
  An ID that uniquely identifies the top-level parent message of the reply
  thread that this message is replying to. The message does not include this
  tag if this message is not a reply.
  """
  @type thread_parent_id :: String.t()

  @typedoc """
  Twitch tag `reply-thread-parent-user-login`.
  The login name of the sender of the top-level parent message. The message
  does not include this tag if this message is not a reply.
  """
  @type thread_user_name :: String.t()

  @typedoc """
  Twitch tag `room-id`.
  The ID of the channel.
  """
  @type channel_id :: String.t()

  @typedoc """
  Twitch tag `slow`.
  An integer value that determines how long, in seconds, users must wait
  between sending messages.
  """
  @type slow_delay :: non_neg_integer()

  @typedoc """
  Twitch tag `subs-only`.
  A Boolean value that determines whether only subscribers and moderators can
  chat in the chat room. Is `true` if only subscribers and moderators can chat;
  otherwise, `false`.
  """
  @type subs_only? :: boolean()

  @typedoc """
  Twitch tag `subscriber`.
  A Boolean value that determines whether the user is a subscriber. Is `true`
  if the user is a subscriber; otherwise, `false`.
  """
  @type sub? :: boolean()

  @typedoc """
  Twitch tag `system-msg`.
  The message Twitch shows in the chat room for this notice.
  """
  @type system_message :: String.t()

  @typedoc """
  Twitch tag `target-msg-id`.
  A UUID that identifies the message that was removed.
  """
  @type target_message_id :: String.t()

  @typedoc """
  Twitch tag `target-user-id`.
  The ID of the user that was banned or put in a timeout. The user was banned
  if the message doesn’t include the `ban-duration` tag.
  """
  @type target_user_id :: String.t()

  @typedoc """
  Twitch tag `thread-id`.
  An ID that uniquely identifies the whisper thread. The ID is in the form,
  `<smaller-value-user-id>_<larger-value-user-id>`.
  """
  @type thread_id :: String.t()

  @typedoc """
  Twitch tag `tmi-sent-ts`.
  The UNIX timestamp converted to a `DateTime` struct.
  """
  @type timestamp :: DateTime.t()

  @typedoc """
  Twitch tag `turbo`.
  A Boolean value that indicates whether the user has site-wide commercial free
  mode enabled. Is `true` if enabled; otherwise, `false`.
  """
  @type turbo? :: String.t()

  @typedoc """
  Twitch tag `user-id`.
  The user’s ID.
  """
  @type user_id :: String.t()

  @typedoc """
  Twitch tag `user-type`.
  The type of user. Possible values are:
   * `:normal` — A normal user
   * `:admin` — A Twitch administrator
   * `:global_mod` — A global moderator
   * `:staff` — A Twitch employee
  """
  @type user_type :: :normal | :admin | :global_mod | :staff

  @typedoc """
  Twitch tag `vip`.
  A Boolean value that determines whether the user that sent the chat is a VIP.
  The message includes this tag if the user is a VIP; otherwise, the message
  doesn’t include this tag (check for the presence of the tag instead of
  whether the tag is set to `true` or `false`).
  """
  @type vip? :: boolean()

  @tag_names %{
    "badge-info" => :badge_info,
    "badges" => :badges,
    "ban-duration" => :ban_duration,
    "bits" => :bits,
    "color" => :color,
    "display-name" => :display_name,
    "emotes" => :emotes,
    "emote-only" => :emote_only?,
    "emote-sets" => :emote_sets,
    "followers-only" => :followers_only?,
    "flags" => :flags,
    "id" => :id,
    "login" => :user_name,
    "message-id" => :message_id,
    "mod" => :mod?,
    "msg-id" => :event,
    "msg-param-community-gift-id" => :community_gift_id,
    "msg-param-cumulative-months" => :cumulative_months,
    "msg-param-displayName" => :display_name,
    "msg-param-gift-months" => :gift_months,
    "msg-param-login" => :user_name,
    "msg-param-mass-gift-count" => :count,
    "msg-param-months" => :cumulative_months,
    "msg-param-origin-id" => :origin_id,
    "msg-param-promo-gift-total" => :promo_gift_total,
    "msg-param-promo-name" => :promo_name,
    "msg-param-recipient-display-name" => :recipient_display_name,
    "msg-param-recipient-id" => :recipient_id,
    "msg-param-recipient-user-name" => :recipient_user_name,
    "msg-param-ritual-name" => :ritual_name,
    "msg-param-sender-count" => :sender_count,
    "msg-param-sender-login" => :sender_user_name,
    "msg-param-sender-name" => :sender_display_name,
    "msg-param-should-share-streak" => :share_streak?,
    "msg-param-streak-months" => :streak_months,
    "msg-param-sub-plan" => :plan,
    "msg-param-sub-plan-name" => :plan_name,
    "msg-param-threshold" => :bits_badge_tier,
    "msg-param-viewerCount" => :viewer_count,
    "pinned-chat-paid-amount" => :amount,
    "pinned-chat-paid-currency" => :currency,
    "pinned-chat-paid-exponent" => :exponent,
    "pinned-chat-paid-is-system-message" => :system_message?,
    "pinned-chat-paid-level" => :level,
    "r9k" => :r9k?,
    "reply-parent-display-name" => :parent_display_name,
    "reply-parent-msg-body" => :parent_message,
    "reply-parent-msg-id" => :parent_id,
    "reply-parent-user-id" => :parent_user_id,
    "reply-parent-user-login" => :parent_user_name,
    "reply-thread-parent-msg-id" => :thread_parent_id,
    "reply-thread-parent-user-login" => :thread_user_name,
    "room-id" => :channel_id,
    "slow" => :slow_delay,
    "subs-only" => :subs_only?,
    "subscriber" => :sub?,
    "system-msg" => :system_message,
    "target-msg-id" => :target_message_id,
    "target-user-id" => :target_user_id,
    "thread-id" => :thread_id,
    "tmi-sent-ts" => :timestamp,
    "turbo" => :turbo?,
    "user-id" => :user_id,
    "user-type" => :user_type,
    "vip" => :vip?
  }

  @supported_tags Map.keys(@tag_names)

  @doc """
  List all of the supported Twitch tags.
  """
  @spec supported_tags() :: [String.t()]
  def supported_tags, do: @supported_tags

  @doc """
  The Twitch tag name to a TMI field name.
  """
  @spec field_from_tag!(String.t()) :: atom()
  def field_from_tag!(tag), do: Map.fetch!(@tag_names, tag)
end
