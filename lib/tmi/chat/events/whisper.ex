defmodule TMI.Chat.Events.Whisper do
  use TMI.Event,
    fields: [
      :id,
      :badge_info,
      :badges,
      :channel,
      :color,
      :display_name,
      :login,
      :emotes,
      :first_message?,
      :message,
      :is_mod?,
      :is_turbo?,
      :is_sub?,
      :is_vip?,
      :returning_chatter?,
      :channel_id,
      :timestamp,
      :user_id,
      :user_login,
      :user_type
    ]
end
