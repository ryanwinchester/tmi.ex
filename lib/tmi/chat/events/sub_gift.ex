defmodule TMI.Chat.Events.SubGift do
  @moduledoc """
  Community sub gift event. A.K.A. `submysterygift`.
  """
  use TMI.Event,
    fields: [
      :id,
      :channel,
      :channel_id,
      :plan,
      :system_message,
      :timestamp,
      :gift_months,
      :gift_theme,
      :is_anon?,
      :plan_name,
      # --- user fields ---
      :badge_info,
      :badges,
      :color,
      :cumulative_months,
      :cumulative_total,
      :display_name,
      :is_mod?,
      :is_turbo?,
      :is_sub?,
      :is_vip?,
      :user_id,
      :user_type,
      # --- recipient fields ---
      :recipient_display_name,
      :recipient_id,
      :recipient_login
    ]
end
