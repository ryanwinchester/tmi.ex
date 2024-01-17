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
      :channel,
      :color,
      :total,
      :display_name,
      :is_mod?,
      :is_turbo?,
      :is_sub?,
      :is_vip?,
      :login,
      :cumulative_total,
      :system_message,
      :timestamp,
      :user_id,
      :user_type,
      :cumulative_months,
      :gift_months
    ]
end
