defmodule TMI.Events.Follow do
  @moduledoc false
  use TMI.Event,
    fields: [
      :broadcaster_user_id,
      :broadcaster_user_login,
      :broadcaster_user_name,
      :followed_at,
      :user_id,
      :user_login,
      :user_name
    ]
end
