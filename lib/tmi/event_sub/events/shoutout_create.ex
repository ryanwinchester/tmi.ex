defmodule TMI.EventSub.Events.ShoutoutCreate do
  @moduledoc false
  use TMI.Event,
    fields: [
      :cooldown_ends_at,
      :broadcaster_id,
      :broadcaster_name,
      :channel,
      :moderator_id,
      :moderator_login,
      :moderator_name,
      :started_at,
      :target_cooldown_ends_at,
      :to_broadcaster_id,
      :to_broadcaster_name,
      :to_channel,
      :viewer_count
    ]
end
