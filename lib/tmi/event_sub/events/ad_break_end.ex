defmodule TMI.EventSub.Events.AdBreakEnd do
  @moduledoc false
  use TMI.Event,
    fields: [
      :broadcaster_id,
      :broadcaster_name,
      :channel,
      :duration_seconds,
      :is_automatic,
      :requester_id,
      :requester_login,
      :requester_name,
      :started_at
    ]
end
