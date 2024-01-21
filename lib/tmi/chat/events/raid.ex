defmodule TMI.Chat.Events.Raid do
  @moduledoc false
  use TMI.Event,
    fields: [
      :badge_info,
      :badges,
      :channel_id,
      :channel,
      :color,
      :display_name,
      :emotes,
      :id,
      :is_mod?,
      :is_turbo?,
      :is_sub?,
      :is_vip?,
      :login,
      :system_message,
      :timestamp,
      :user_id,
      :user_type,
      :viewer_count,
      :profile_image_url
    ]
end
