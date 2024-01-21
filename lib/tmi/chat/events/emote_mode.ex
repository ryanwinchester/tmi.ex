defmodule TMI.Chat.Events.EmoteMode do
  @moduledoc false
  use TMI.Event,
    fields: [
      :channel,
      :emote_only?
    ]
end
