defmodule TMI.Events.Sub do
  @moduledoc """
  Sub event.
  IRC `msg-id` is `sub` and EventSub name is `sub`.
  """
  use TMI.Event,
    fields: [
      :id,
      :channel_id,
      :channel,
      :plan,
      :plan_name,
      :system_message,
      :timestamp,
      :gifted?,
      :goal_type,
      :goal_current,
      :goal_target,
      :goal_contributions,
      :share_streak?,
      :months,
      :badge_info,
      :badges,
      :color,
      :cumulative_months,
      :login,
      :display_name,
      :is_mod?,
      :is_turbo?,
      :is_sub?,
      :is_vip?,
      :user_id,
      :user_type
    ]
end
