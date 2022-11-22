defmodule TMI.Events.Notice do
  @type notice_type ::
          :already_banned
          | :already_emote_only_on
          | :already_emote_only_off
          | :already_subs_on
          | :already_subs_off
          | :bad_ban_admin
          | :bad_ban_broadcaster
          | :bad_ban_global_mod
          | :bad_ban_self
          | :bad_ban_staff
          | :bad_commercial_error
          | :bad_host_hosting
          | :bad_host_rate_exceeded
          | :bad_mod_mod
          | :bad_mod_banned
          | :bad_timeout_admin
          | :bad_timeout_global_mod
          | :bad_timeout_self
          | :bad_timeout_staff
          | :bad_unban_no_ban
          | :bad_unmod_mod
          | :ban_success
          | :cmds_available
          | :color_changed
          | :commercial_success
          | :emote_only_on
          | :emote_only_off
          | :host_off
          | :host_on
          | :hosts_remaining
          | :host_target_went_offline
          | :mod_success
          | :msg_banned
          | :msg_censored_broadcaster
          | :msg_channel_suspended
          | :msg_duplicate
          | :msg_emoteonly
          | :msg_ratelimit
          | :msg_subsonly
          | :msg_timedout
          | :msg_verified_email
          | :no_help
          | :no_mods
          | :no_permission
          | :not_hosting
          | :r9k_off
          | :r9k_on
          | :room_mods
          | :slow_off
          | :slow_on
          | :subs_off
          | :subs_on
          | :timeout_success
          | :unban_success
          | :unmod_success
          | :unrecognized_cmd
          | :usage_ban
          | :usage_clear
          | :usage_color
          | :usage_commercial
          | :usage_disconnect
          | :usage_emote_only_on
          | :usage_emote_only_off
          | :usage_help
          | :usage_host
          | :usage_me
          | :usage_mod
          | :usage_mods
          | :usage_r9k_on
          | :usage_r9k_off
          | :usage_slow_on
          | :usage_slow_off
          | :usage_subs_on
          | :usage_subs_off
          | :usage_timeout
          | :usage_unban
          | :usage_unhost
          | :usage_unmod
          | :whisper_invalid_self
          | :whisper_limit_per_min
          | :whisper_limit_per_sec
          | :whisper_restricted_recipient

  @type t :: %__MODULE__{
    channel: String.t(),
    message: String.t(),
    type: notice_type(),
    tags: [%{optional(String.t() => String.t()}]
  }

  # The following msg-ids are already covered by other events.
  @duplicate_types [
    :host_off,
    :host_on,
    :no_mods,
    :r9k_off,
    :r9k_on,
    :room_mods,
    :slow_off,
    :slow_on,
    :subs_off,
    :subs_on
  ]

  @enforce_keys [:channel, :message, :type, :tags]
  defstruct [:channel, :message, :type, :tags]

  @doc """
  Return the types that are ignored, because they are already handled in a
  different event.
  """
  @spec duplicate_types() :: [notice_type()]
  def duplicate_types, do: @duplicate_types
end
