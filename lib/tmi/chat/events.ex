defmodule TMI.Chat.Events do
  @moduledoc false

  @events %{
    announcement: TMI.Chat.Events.Announcement,
    charity_donation: TMI.Chat.Events.CharityDonation,
    channel_update: TMI.Chat.Events.ChannelUpdate,
    cheer: TMI.Chat.Events.Cheer,
    ban: TMI.Chat.Events.Ban,
    unban: TMI.Chat.Events.Unban,
    moderator_add: TMI.Chat.Events.ModeratorAdd,
    moderator_remove: TMI.Chat.Events.ModeratorRemove,
    guest_star_session_begin: TMI.Chat.Events.GuestStarSessionBegin,
    guest_star_session_end: TMI.Chat.Events.GuestStarSessionEnd,
    guest_star_guest: TMI.Chat.Events.GuestStarGuest,
    guest_star_settings_update: TMI.Chat.Events.GuestStarSettingsUpdate,
    clear: TMI.Chat.Events.Clear,
    clear_user_messages: TMI.Chat.Events.ClearUserMessages,
    message_delete: TMI.Chat.Events.MessageDelete,
    message: TMI.Chat.Events.Message,
    chat_action: TMI.Chat.Events.ChatAction,
    whisper: TMI.Chat.Events.Whisper,
    cheermote: TMI.Chat.Events.Cheermote,
    emote_mode: TMI.Chat.Events.EmoteMode,
    mention: TMI.Chat.Events.Mention,
    setting_update: TMI.Chat.Events.SettingUpdate,
    ad_break: TMI.Chat.Events.AdBreak,
    sub: TMI.Chat.Events.Sub,
    sub_message: TMI.Chat.Events.SubMessage,
    sub_end: TMI.Chat.Events.SubEnd,
    resub: TMI.Chat.Events.Resub,
    sub_gift: TMI.Chat.Events.SubGift,
    community_sub_gift: TMI.Chat.Events.CommunitySubGift,
    gift_paid_upgrade: TMI.Chat.Events.GiftPaidUpgrade,
    prime_paid_upgrade: TMI.Chat.Events.PrimePaidUpgrade,
    raid: TMI.Chat.Events.Raid,
    unraid: TMI.Chat.Events.Unraid,
    pay_it_forward: TMI.Chat.Events.PayItForward,
    reward_add: TMI.Chat.Events.RewardAdd,
    reward_remove: TMI.Chat.Events.RewardRemove,
    reward_redemption: TMI.Chat.Events.RewardRedemption,
    reward_redemption_update: TMI.Chat.Events.RewardRedemptionUpdate,
    poll_begin: TMI.Chat.Events.PollBegin,
    poll_progress: TMI.Chat.Events.PollProgress,
    poll_end: TMI.Chat.Events.PollEnd,
    prediction_begin: TMI.Chat.Events.PredictionBegin,
    prediction_progress: TMI.Chat.Events.PredictionProgress,
    prediction_end: TMI.Chat.Events.PredictionEnd,
    charity_campaign_donate: TMI.Chat.Events.CharityCampaignDonate,
    charity_campaign_progress: TMI.Chat.Events.CharityCampaignProgress,
    charity_campaign_start: TMI.Chat.Events.CharityCampaignStart,
    charity_campaign_stop: TMI.Chat.Events.CharityCampaignStop,
    drop_entitlement_grant: TMI.Chat.Events.DropEntitlementGrant,
    extension_bit_transaction: TMI.Chat.Events.ExtensionBitTransaction,
    goal_begin: TMI.Chat.Events.GoalBegin,
    goal_progress: TMI.Chat.Events.GoalProgress,
    goal_end: TMI.Chat.Events.GoalEnd,
    hype_train_begin: TMI.Chat.Events.HypeTrainBegin,
    hype_train_progress: TMI.Chat.Events.HypeTrainProgress,
    hype_train_end: TMI.Chat.Events.HypeTrainEnd,
    shield_mode_begin: TMI.Chat.Events.ShieldModeBegin,
    shield_mode_end: TMI.Chat.Events.ShieldModeEnd,
    stream_online: TMI.Chat.Events.StreamOnline,
    stream_offline: TMI.Chat.Events.StreamOffline,
    user_auth_grant: TMI.Chat.Events.UserAuthGrant,
    user_auth_revoke: TMI.Chat.Events.UserAuthRevoke,
    user_update: TMI.Chat.Events.UserUpdate,
    viewer_milestone: TMI.Chat.Events.ViewerMilestone,
    unrecognized: TMI.Chat.Events.Unrecognized
  }

  @event_names Map.keys(@events)

  # Generate the AST for all the module's struct types as a union
  # like `TMI.Chat.Events.Cheer.t() | TMI.Chat.Events.Cheermote` etc...
  event_types =
    Map.values(@events)
    |> Enum.sort()
    |> Enum.reduce(&{:|, [], [{{:., [], [&1, :t]}, [], []}, &2]})

  @typedoc """
  The event type union of event struct types.
  """
  @type event :: unquote(event_types)

  @typedoc """
  The params for an event as an atom-keyed map.
  """
  @type event_params :: %{required(atom()) => any()}

  @doc """
  Generate an event struct from the event params.
  """
  @spec from_map(event_params()) :: event()
  def from_map(params, extras \\ %{})

  # Matching on specific special-cases of events here.
  # Some events are _actually_ other events, with some extra fields.
  # For example, having events like `:highlighted_message` would be tedious to
  # match on all the different message variations instead of just having a
  # `Message` struct with a `:highlighted?` field.

  def from_map(%{event: :emote_only_off} = params, extras) do
    from_map_with_name(params, :emote_mode, Map.merge(extras, %{emote_only?: false}))
  end

  def from_map(%{event: :emote_only_on} = params, extras) do
    from_map_with_name(params, :emote_mode, Map.merge(extras, %{emote_only?: true}))
  end

  def from_map(%{event: :highlighted_message} = params, extras) do
    from_map_with_name(params, :message, Map.merge(extras, %{highlighted?: true}))
  end

  # Generate functions for all the general-cases of events.
  for {name, module} <- @events do
    def from_map(%{event: unquote(name)} = params, extras) do
      struct(unquote(module), Map.merge(params, extras))
    end
  end

  @doc """
  Generate an event struct from the event params, based on the passed in event
  name.
  """
  @spec from_map_with_name(event_params(), atom(), event_params()) :: event()
  def from_map_with_name(map, event_name, extras \\ %{}) when event_name in @event_names do
    @events
    |> Map.fetch!(event_name)
    |> struct(Map.merge(map, extras))
  end
end
