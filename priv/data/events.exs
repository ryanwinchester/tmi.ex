# ------------------------------------------------------------------------------
# Common properties.
# ------------------------------------------------------------------------------
# Properties are a three-tuple that has the name, tag, and description.
# e.g. `{property_name, twitch_tag, description}`.

usernotice_properties = [
  {:channel, "room-id", "An ID that identifies the chat room (channel)."},
  {:message, "system-msg", "The message Twitch shows in the chat room for this notice."},
  {:user, "login", "The login name of the user whose action generated the message."},
  {:user_id, "user-id", "The user's ID."},
  {:is_mod, "mod", "A Boolean value that determines whether the user is a moderator."},
  {:is_sub, "subscriber", "A Boolean value that determines whether the user is a subscriber."},
  {:is_turbo, "turbo", "A Boolean value that indicates whether the user has site-wide commercial free mode enabled."},
  {:badges, "badges", """
  A list of chat badges in the form, <badge>/<version>. For example, admin/1.
  There are many possible badge values, but here are few:
   - admin
   - bits
   - broadcaster
   - moderator
   - subscriber
   - staff
   - turbo
  Most badges have only 1 version, but some badges like subscriber badges
  offer different versions of the badge depending on how long the user has
  subscribed.
  """},
  {:timestamp, "tmi-sent-ts", "The UNIX timestamp for when the Twitch IRC server received the message."}
]

# ------------------------------------------------------------------------------
# Events.
# ------------------------------------------------------------------------------
# Events describe the events we get from Twitch in the form of messages and
# commonly, they are further split by `msg-id` tags..

[
  %{
    "name" => "GiftSub",
    "message" => "USERNOTICE",
    "msg-id" => "subgift",
    "properties" => usernotice_properties ++ [
      {:months, "msg-param-months", "The total number of months the user has subscribed."},
      {:recipient_display_name, "msg-param-recipient-display-name", "The display name of the subscription gift recipient."},
      {:recipient_id, "msg-param-recipient-id", "The user ID of the subscription gift recipient."},
      {:recipient_user_name, "msg-param-recipient-user-name", "The user name of the subscription gift recipient."},
      {:sub_plan, "msg-param-sub-plan", """
      The type of subscription plan being used. Possible values are:
       - Prime — Amazon Prime subscription
       - 1000 — First level of paid subscription
       - 2000 — Second level of paid subscription
       - 3000 — Third level of paid subscription
      """},
      {:sub_plan_name, "msg-param-sub-plan-name", "The display name of the subscription plan. This may be a default name or one created by the channel owner."},
      {:gift_months, "msg-param-gift-months", "The number of months gifted as part of a single, multi-month gift."}
    ]
  },

  # TODO: MORE...
]
