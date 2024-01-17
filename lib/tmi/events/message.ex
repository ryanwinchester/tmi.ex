defmodule TMI.Events.Message do
  use TMI.Event,
    fields: [
      :id,
      :channel,
      :badge_info,
      :badges,
      :color,
      :display_name,
      :login,
      :emotes,
      :first_message?,
      :highlighted?,
      :message,
      :is_mod?,
      :is_turbo?,
      :is_sub?,
      :returning_chatter?,
      :channel_id,
      :timestamp,
      :user_id,
      :user_login,
      :user_type,
      :reward_id
    ]
end
