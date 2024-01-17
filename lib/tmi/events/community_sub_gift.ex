defmodule TMI.Events.CommunitySubGift do
  @moduledoc """
  Gift sub event.
  This is when someone gifts subs to the community.
  It will be followed by `n` `TMI.Events.SubGift` events, where `n` is the
  `:total` ammount of gift subs.
  """
  use TMI.Event,
    fields: [
      :id,
      :channel,
      :badge_info,
      :badges,
      :channel_id,
      :color,
      :goal_type,
      :goal_current,
      :goal_target,
      :goal_contributions,
      :total,
      # :community_gift_id,
      :display_name,
      :emotes,
      :event,
      :is_mod?,
      :is_turbo?,
      :is_sub?,
      :is_vip?,
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
