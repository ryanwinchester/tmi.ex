defmodule TMI.Chat.Events.ChannelUpdate do
  @moduledoc """
  When we get a ROOMSTATE notice in IRC or a chat settings update from EventSub.
  """
  use TMI.Event,
    fields: [
      :emote_only?,
      :followers_only?,
      :unique_only?,
      :subs_only?,
      :slow_delay,
      :channel_id,
      :channel
    ]
end
