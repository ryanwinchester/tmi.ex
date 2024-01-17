defmodule TMI.Events.ChannelUpdate do
  @moduledoc """
  When we get a ROOMSTATE notice in IRC or a chat settings update from EventSub.
  """
  use TMI.Event, fields: [
    # TODO: Follower-only, sub-only, slow-mode, unique (is that r9k?)?
    :emote_only?,
    :channel_id,
    :channel
  ]
end
