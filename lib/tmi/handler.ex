defmodule TMI.Handler do
  @moduledoc """
  Handler behaviour for TMI.
  """

  @doc "Handle a `TMI` event."
  @doc since: "0.7.0"
  @callback handle_event(struct()) :: any()

  # ----------------------------------------------------------------------------
  # Deprecated callbacks
  # ----------------------------------------------------------------------------

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_action(message :: String.t(), sender :: String.t(), String.t()) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_action(String.t(), String.t(), String.t(), map()) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_connected(server :: String.t(), port :: integer) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_disconnected() :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_join(channel :: String.t()) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_join(channel :: String.t(), user :: String.t()) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_kick(channel :: String.t(), kicker :: String.t()) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_kick(channel :: String.t(), user :: String.t(), kicker :: String.t()) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_logged_in() :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_login_failed(reason :: atom) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_message(message :: String.t(), sender :: String.t(), String.t()) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_message(String.t(), String.t(), String.t(), map()) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_mention(message :: String.t(), sender :: String.t(), String.t()) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_part(channel :: String.t()) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_part(channel :: String.t(), user :: String.t()) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_unrecognized(msg :: any()) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_unrecognized(msg :: any(), tags :: map()) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_whisper(message :: String.t(), sender :: String.t()) :: any()

  @doc deprecated: "Use handle_event/1 instead"
  @callback handle_whisper(message :: String.t(), sender :: String.t(), tags :: map()) :: any()

  # Obviously the deprecated callbacks need to be optional.
  @optional_callbacks [
    handle_action: 3,
    handle_action: 4,
    handle_connected: 2,
    handle_disconnected: 0,
    handle_join: 1,
    handle_join: 2,
    handle_kick: 2,
    handle_kick: 3,
    handle_logged_in: 0,
    handle_login_failed: 1,
    handle_message: 3,
    handle_message: 4,
    handle_mention: 3,
    handle_part: 1,
    handle_part: 2,
    handle_unrecognized: 1,
    handle_unrecognized: 2,
    handle_whisper: 2,
    handle_whisper: 3
  ]
end
