defmodule TMI.Events.PayItForward do
  @moduledoc """
  Gift sub event.
  """
  use TMI.Event,
    fields: [
      :id,
      :badge_info,
      :badges,
      :channel_id,
      :color,
      :total,
      # :community_gift_id,
      :display_name,
      :emotes,
      :event,
      :mod?,
      :sub?,
      :vip?,
      :login,
      # :origin_id,
      :plan,
      :cumulative_total,
      :system_message,
      :timestamp,
      :user_id,
      :user_type,
      :cumulative_months,
      :gift_months,
      :plan_name,
      :recipient_display_name,
      :recipient_id,
      :recipient_login
    ]
end
