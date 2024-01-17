defmodule TMI.Events.EmoteMode do
  @moduledoc false
  use TMI.Event, fields: [
    :channel,
    :emote_only?
  ]
end
