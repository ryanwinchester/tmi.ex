defmodule TMI.Events.ShoutoutCreate do
  @moduledoc false
  use TMI.Event,
    fields: [
      :broadcaster_user_id,
      :broadcaster_user_login,
      :broadcaster_user_name,
      :cooldown_ends_at,
      :moderator_user_id,
      :moderator_user_login,
      :moderator_user_name,
      :started_at,
      :target_cooldown_ends_at,
      :to_broadcaster_user_id,
      :to_broadcaster_user_login,
      :to_broadcaster_user_name,
      :viewer_count
    ]
end
