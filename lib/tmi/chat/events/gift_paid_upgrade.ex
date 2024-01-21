defmodule TMI.Chat.Events.GiftPaidUpgrade do
  @moduledoc """
  Sub event after getting a gift sub.
  IRC `msg-id` is `giftpaidupgrade` and EventSub name is `gift_paid_upgrade`.
  """
  use TMI.Event,
    fields: [
      :id,
      :channel_id,
      :plan,
      :plan_name,
      :system_message,
      :timestamp,
      :goal_type,
      :goal_current,
      :goal_target,
      :goal_contributions,
      :share_streak?,
      # --- user fields ---
      :badge_info,
      :badges,
      :color,
      :cumulative_months,
      :login,
      :display_name,
      :is_mod?,
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
