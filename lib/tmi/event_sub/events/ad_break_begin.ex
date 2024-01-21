defmodule TMI.EventSub.Events.AdBreakBegin do
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
