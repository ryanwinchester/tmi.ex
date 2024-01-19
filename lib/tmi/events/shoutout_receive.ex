defmodule TMI.Events.ShoutoutReceive do
  @moduledoc false
  use TMI.Event,
    fields: [
      :broadcaster_user_id,
      :broadcaster_user_login,
      :broadcaster_user_name,
      :from_broadcaster_user_id,
      :from_broadcaster_user_login,
      :from_broadcaster_user_name,
      :started_at,
      :viewer_count
    ]
end
