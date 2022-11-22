defmodule TMI.Events.Ban do
  @enforce_keys [:channel, :user, :user_id, :room_id, :tags]
  defstruct [:channel, :user, :user_id, :room_id, :tags]
end
