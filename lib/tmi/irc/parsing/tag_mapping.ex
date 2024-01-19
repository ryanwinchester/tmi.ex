defmodule TMI.IRC.Parsing.TagMapping do
  @moduledoc false

  @tag_fields %{
    "badge-info" => :badge_info,
    "badges" => :badges,
    "ban-duration" => :ban_duration,
    "bits" => :bits,
    "client-nonce" => :client_nonce,
    "color" => :color,
    "custom-reward-id" => :reward_id,
    "display-name" => :display_name,
    "emotes" => :emotes,
    "emote-only" => :emote_only?,
    "emote-sets" => :emote_sets,
    "first-msg" => :first_message?,
    "flags" => :flags,
    "followers-only" => :followers_only?,
    "id" => :id,
    "login" => :login,
    "message-id" => :message_id,
    "mod" => :is_mod?,
    "msg-id" => :event,
    "msg-param-category" => :milestone,
    "msg-param-copoReward" => :channel_points,
    "msg-param-id" => :ignore,
    "msg-param-value" => :total,
    "msg-param-community-gift-id" => :community_gift_id,
    "msg-param-cumulative-months" => :cumulative_months,
    "msg-param-displayName" => :display_name,
    "msg-param-gift-months" => :gift_months,
    "msg-param-gift-theme" => :gift_theme,
    "msg-param-goal-contribution-type" => :goal_type,
    "msg-param-goal-current-contributions" => :goal_current,
    "msg-param-goal-description" => :goal_description,
    "msg-param-goal-target-contributions" => :goal_target,
    "msg-param-goal-user-contributions" => :goal_contributions,
    "msg-param-login" => :login,
    "msg-param-mass-gift-count" => :total,
    "msg-param-months" => :months,
    # Not sure about these next two.
    "msg-param-multimonth-duration" => :multimonth_duration,
    "msg-param-multimonth-tenure" => :multimonth_tenure,
    # I don't know what multimonth-tenure is. I have a message
    # that has cumulative-months=1 and multimonth-tenure=0.
    # "msg-param-multimonth-tenure" => :what?,
    "msg-param-origin-id" => :origin_id,
    "msg-param-profileImageURL" => :profile_image_url,
    "msg-param-prior-gifter-anonymous" => :prior_gifter_anon?,
    "msg-param-prior-gifter-display-name" => :prior_gifter_display_name,
    "msg-param-prior-gifter-id" => :prior_gifter_id,
    "msg-param-prior-gifter-user-name" => :prior_gifter_login,
    "msg-param-promo-gift-total" => :promo_gift_total,
    "msg-param-promo-name" => :promo_name,
    "msg-param-recipient-display-name" => :recipient_display_name,
    "msg-param-recipient-id" => :recipient_id,
    "msg-param-recipient-user-name" => :recipient_login,
    "msg-param-ritual-name" => :ritual_name,
    "msg-param-sender-count" => :cumulative_total,
    "msg-param-sender-login" => :sender_login,
    "msg-param-sender-name" => :sender_display_name,
    "msg-param-should-share-streak" => :share_streak?,
    "msg-param-streak-months" => :streak_months,
    "msg-param-sub-plan" => :plan,
    "msg-param-sub-plan-name" => :plan_name,
    "msg-param-threshold" => :bits_badge_tier,
    "msg-param-viewerCount" => :viewer_count,
    "msg-param-was-gifted" => :gifted?,
    "pinned-chat-paid-amount" => :amount,
    "pinned-chat-paid-currency" => :currency,
    "pinned-chat-paid-exponent" => :exponent,
    "pinned-chat-paid-is-system-message" => :system_message?,
    "pinned-chat-paid-level" => :level,
    "r9k" => :unique_only?,
    "reply-parent-display-name" => :parent_user_display_name,
    "reply-parent-msg-body" => :parent_message,
    "reply-parent-msg-id" => :parent_id,
    "reply-parent-user-id" => :parent_user_id,
    "reply-parent-user-login" => :parent_user_login,
    "reply-thread-parent-display-name" => :thread_parent_user_display_name,
    "reply-thread-parent-msg-id" => :thread_parent_id,
    "reply-thread-parent-user-id" => :thread_parent_user_id,
    "reply-thread-parent-user-login" => :thread_parent_user_login,
    "returning-chatter" => :returning_chatter?,
    "room-id" => :channel_id,
    "slow" => :slow_delay,
    "subs-only" => :subs_only?,
    "subscriber" => :is_sub?,
    "system-msg" => :system_message,
    "target-msg-id" => :target_message_id,
    "target-user-id" => :target_user_id,
    "thread-id" => :thread_id,
    "tmi-sent-ts" => :timestamp,
    "turbo" => :is_turbo?,
    "user-id" => :user_id,
    "user-type" => :user_type,
    "vip" => :is_vip?
  }

  @supported_tags Map.keys(@tag_fields)

  @doc """
  List all of the supported Twitch IRC tags.
  """
  @spec supported_tags() :: [String.t()]
  def supported_tags, do: @supported_tags

  @doc """
  The Twitch IRC tag name to a TMI field name.
  """
  @spec field_from_tag!(String.t()) :: atom()
  def field_from_tag!(tag), do: Map.fetch!(@tag_fields, tag)
end
