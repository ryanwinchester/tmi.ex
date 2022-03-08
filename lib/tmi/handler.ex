defmodule TMI.Handler do
  @moduledoc """
  Handler behaviour for TMI.
  """

  @callback handle_action(message :: String.t(), sender :: String.t(), channel :: String.t()) ::
              any

  @callback handle_connected(server :: String.t(), port :: integer) :: any

  @callback handle_disconnected() :: any

  @callback handle_join(channel :: String.t()) :: any

  @callback handle_join(channel :: String.t(), user :: String.t()) :: any

  @callback handle_kick(channel :: String.t(), kicker :: String.t()) :: any

  @callback handle_kick(channel :: String.t(), user :: String.t(), kicker :: String.t()) :: any

  @callback handle_logged_in() :: any

  @callback handle_login_failed(reason :: atom) :: any

  @callback handle_message(message :: String.t(), sender :: String.t(), channel :: String.t()) ::
              any

  @callback handle_mention(message :: String.t(), sender :: String.t(), channel :: String.t()) ::
              any

  @callback handle_part(channel :: String.t()) :: any

  @callback handle_part(channel :: String.t(), user :: String.t()) :: any

  @callback handle_unrecognized(msg :: any) :: any

  @callback handle_whisper(message :: String.t(), sender :: String.t()) :: any
end
