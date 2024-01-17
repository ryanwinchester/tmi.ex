defmodule TMI.Events.EmoteMode do
  @moduledoc false
  use TMI.Event, fields: [
    :emote_only?
  ]
end
