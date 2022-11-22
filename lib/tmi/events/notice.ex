defmodule TMI.Events.Notice do
  @type notice_type ::
          :already_banned
          # This room is already in emote-only mode.
          | :already_emote_only_on
          # This room is not in emote-only mode.
          | :already_emote_only_off
          # This room is already in subscribers-only mode.
          | :already_subs_on
          # This room is not in subscribers-only mode.
          | :already_subs_off
          # You cannot ban admin X.
          | :bad_ban_admin
          # You cannot ban the broadcaster.
          | :bad_ban_broadcaster
          # You cannot ban global moderator X.
          | :bad_ban_global_mod
          # You cannot ban yourself.
          | :bad_ban_self
          # You cannot ban staff X.
          | :bad_ban_staff
          # Failed to start commercial.
          | :bad_commercial_error
          # This channel is already hosting X.
          | :bad_host_hosting
          # Host target cannot be changed more than 3 times every half hour.
          | :bad_host_rate_exceeded
          # X is already a moderator of this room.
          | :bad_mod_mod
          # X is banned in this room.
          | :bad_mod_banned
          # You cannot timeout admin X.
          | :bad_timeout_admin
          # You cannot timeout global moderator X.
          | :bad_timeout_global_mod
          # You cannot timeout yourself.
          | :bad_timeout_self
          # You cannot timeout staff X.
          | :bad_timeout_staff
          # X is not banned from this room.
          | :bad_unban_no_ban
          # X is not a moderator of this room.
          | :bad_unmod_mod
          # X is now banned from this room.
          | :ban_success
          # Commands available to you in this room (use /help for details)..
          | :cmds_available
          # Your color has been changed.
          | :color_changed
          # Initiating X second commercial break. Please keep in mind..
          | :commercial_success
          # This room is now in emote-only mode.
          | :emote_only_on
          # This room is no longer in emote-only mode.
          | :emote_only_off
          # X host commands remaining this half hour.
          | :hosts_remaining
          # X has gone offline. Exiting host mode
          | :host_target_went_offline
          # You have added X as a moderator of this room.
          | :mod_success
          # You are permanently banned from talking in channel.
          | :msg_banned
          # Your message was modified for using words banned by X.
          | :msg_censored_broadcaster
          # This channel has been suspended.
          | :msg_channel_suspended
          # Your message was not sent because you are sending messages too quickly.
          | :msg_duplicate
          # This room is in emote only mode.
          | :msg_emoteonly
          # Your message was not sent because you are sending messages too quickly.
          | :msg_ratelimit
          # This room is in subscribers only mode. To talk, purchase..
          | :msg_subsonly
          # You are banned from talking in X for Y more seconds.
          | :msg_timedout
          # This room requires a verified email address to chat.
          | :msg_verified_email
          # No help available.
          | :no_help
          # You don't have permission to perform that action.
          | :no_permission
          # No channel is currently being hosted.
          | :not_hosting
          # X has been timed out for length seconds.
          | :timeout_success
          # X is no longer banned from this room.
          | :unban_success
          # You have removed X as a moderator of this room.
          | :unmod_success
          # Unrecognized command: X
          | :unrecognized_cmd
          # Usage: "/ban " - Permanently prevent a user from chatting..
          | :usage_ban
          # Usage: "/clear" - Clear chat history for all users in this room.
          | :usage_clear
          # Usage: "/color " - Change your username color. Color must be..
          | :usage_color
          # Usage: "/commercial [length]" - Triggers a commercial.
          | :usage_commercial
          # Usage: "/disconnect" - Reconnects to chat.
          | :usage_disconnect
          # Usage: "/emoteonly" - Enables emote-only mode..
          | :usage_emote_only_on
          # Usage: "/emoteonlyoff" - Disables emote-only mode..
          | :usage_emote_only_off
          # Usage: "/help" - Lists the commands available to you in this room.
          | :usage_help
          # Usage: "/host " - Host another channel. Use "unhost" to unset host mode.
          | :usage_host
          # Usage: "/me " - Send an "emote" message in the third person.
          | :usage_me
          # Usage: "/mod " - Grant mod status to a user. Use "mods" to list the..
          | :usage_mod
          # Usage: "/mods" - Lists the moderators of this channel.
          | :usage_mods
          # Usage: "/r9kbeta" - Enables r9k mode. See http://bit.ly/bGtBDf for details.
          | :usage_r9k_on
          # Usage: "/r9kbetaoff" - Disables r9k mode.
          | :usage_r9k_off
          # Usage: "/slow [duration]" - Enables slow mode..
          | :usage_slow_on
          # Usage: "/slowoff" - Disables slow mode.
          | :usage_slow_off
          # Usage: "/subscribers" - Enables subscribers-only mode..
          | :usage_subs_on
          # Usage: "/subscribersoff" - Disables subscribers-only mode.
          | :usage_subs_off
          # Usage: "/timeout [duration]" - Temporarily prevent a user from chatting.
          | :usage_timeout
          # Usage: "/unban " - Removes a ban on a user.
          | :usage_unban
          # Usage: "/unhost" - Stop hosting another channel.
          | :usage_unhost
          # Usage: "/unmod " - Revoke mod status from a user..
          | :usage_unmod
          # You cannot whisper to yourself.
          | :whisper_invalid_self
          # You are sending whispers too fast. Try again in a minute.
          | :whisper_limit_per_min
          # You are sending whispers too fast. Try again in a second.
          | :whisper_limit_per_sec
          # That user's settings prevent them from receiving this whisper.
          | :whisper_restricted_recipient

  # The following msg-ids wont be returned in the notice event because theyare
  # already available as event listeners:
  @ignored_types [
    # Exited hosting mode.
    :host_off,
    # Now hosting X
    :host_on,
    # There are no moderators for this room.
    :no_mods,
    # This room is no longer in r9k mode.
    :r9k_off,
    # This room is now in r9k mode.
    :r9k_on,
    # The moderators of this room are X
    :room_mods,
    # This room is no longer in slow mode.
    :slow_off,
    # This room is now in slow mode. You may send messages every X seconds.
    :slow_on,
    # This room is no longer in subscribers-only mode.
    :subs_off,
    # This room is now in subscribers-only mode.
    :subs_on
  ]

  @enforce_keys [:channel, :message, :type, :tags]
  defstruct [:channel, :message, :type, :tags]

  @doc """
  Return the types that are ignored, because they are already handled in a
  different event.
  """
  @spec ignored_types() :: [atom()]
  def ignored_types, do: @ignored_types
end
