defmodule TMI.Event do
  @moduledoc false
  # Behaviour and implementation of Events.
  #
  # Use a list of `:fields` to build the struct and struct type for an event
  # module.
  #
  # This isn't great because we will only see the types in the LSP and docs.
  # However, it saves me a lot of time while writing this library.
  #
  # In the future I will either figure out some way to do codegen or manually
  # build the structs and types.
  #
  # ## Options
  #
  #   * `:fields` - A list of field names. Must match the types in `TMI.Fields`.
  #      Required.
  #
  # ## Example
  #
  #     defmodule TMI.Events.Foo
  #       use TMI.Event, fields: [:foo, :bar]
  #     end
  #

  @events %{
    announcement: TMI.Events.Announcement,
    charity_donation: TMI.Events.CharityDonation,
    channel_update: TMI.Events.ChannelUpdate,
    cheer: TMI.Events.Cheer,
    ban: TMI.Events.Ban,
    unban: TMI.Events.Unban,
    moderator_add: TMI.Events.ModeratorAdd,
    moderator_remove: TMI.Events.ModeratorRemove,
    guest_star_session_begin: TMI.Events.GuestStarSessionBegin,
    guest_star_session_end: TMI.Events.GuestStarSessionEnd,
    guest_star_guest: TMI.Events.GuestStarGuest,
    guest_star_settings_update: TMI.Events.GuestStarSettingsUpdate,
    clear: TMI.Events.Clear,
    clear_user_messages: TMI.Events.ClearUserMessages,
    message_delete: TMI.Events.MessageDelete,
    message: TMI.Events.Message,
    chat_action: TMI.Events.ChatAction,
    whisper: TMI.Events.Whisper,
    cheermote: TMI.Events.Cheermote,
    emote: TMI.Events.Emote,
    mention: TMI.Events.Mention,
    setting_update: TMI.Events.SettingUpdate,
    follow: TMI.Events.Follow,
    ad_break: TMI.Events.AdBreak,
    sub: TMI.Events.Sub,
    sub_message: TMI.Events.SubMessage,
    sub_end: TMI.Events.SubEnd,
    resub: TMI.Events.Resub,
    sub_gift: TMI.Events.SubGift,
    community_sub_gift: TMI.Events.CommunitySubGift,
    gift_paid_upgrade: TMI.Events.GiftPaidUpgrade,
    prime_paid_upgrade: TMI.Events.PrimePaidUpgrade,
    raid: TMI.Events.Raid,
    unraid: TMI.Events.Unraid,
    pay_it_forward: TMI.Events.PayItForward,
    reward_add: TMI.Events.RewardAdd,
    reward_remove: TMI.Events.RewardRemove,
    reward_redemption: TMI.Events.RewardRedemption,
    reward_redemption_update: TMI.Events.RewardRedemptionUpdate,
    poll_begin: TMI.Events.PollBegin,
    poll_progress: TMI.Events.PollProgress,
    poll_end: TMI.Events.PollEnd,
    prediction_begin: TMI.Events.PredictionBegin,
    prediction_progress: TMI.Events.PredictionProgress,
    prediction_end: TMI.Events.PredictionEnd,
    charity_campaign_donate: TMI.Events.CharityCampaignDonate,
    charity_campaign_progress: TMI.Events.CharityCampaignProgress,
    charity_campaign_start: TMI.Events.CharityCampaignStart,
    charity_campaign_stop: TMI.Events.CharityCampaignStop,
    drop_entitlement_grant: TMI.Events.DropEntitlementGrant,
    extension_bit_transaction: TMI.Events.ExtensionBitTransaction,
    goal_begin: TMI.Events.GoalBegin,
    goal_progress: TMI.Events.GoalProgress,
    goal_end: TMI.Events.GoalEnd,
    hype_train_begin: TMI.Events.HypeTrainBegin,
    hype_train_progress: TMI.Events.HypeTrainProgress,
    hype_train_end: TMI.Events.HypeTrainEnd,
    shield_mode_begin: TMI.Events.ShieldModeBegin,
    shield_mode_end: TMI.Events.ShieldModeEnd,
    shoutout_create: TMI.Events.ShoutoutCreate,
    shoutout_receive: TMI.Events.ShoutoutReceive,
    stream_online: TMI.Events.StreamOnline,
    stream_offline: TMI.Events.StreamOffline,
    user_auth_grant: TMI.Events.UserAuthGrant,
    user_auth_revoke: TMI.Events.UserAuthRevoke,
    user_update: TMI.Events.UserUpdate,
    viewer_milestone: TMI.Events.ViewerMilestone
  }

  @event_names Map.keys(@events)

  # Generate the AST for all the module's struct types as a union
  # like `TMI.Events.Cheer.t() | TMI.Events.Cheermote` etc...
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

  @doc false
  defmacro __using__(opts) do
    fields = Keyword.fetch!(opts, :fields)

    field_types =
      for field_name <- fields do
        {field_name, quote(do: TMI.Fields.unquote(field_name))}
      end

    quote do
      @type t :: %__MODULE__{unquote_splicing(field_types)}
      defstruct(unquote(fields))
    end
  end
end
