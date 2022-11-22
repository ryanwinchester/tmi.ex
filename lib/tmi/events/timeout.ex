defmodule TMI.Events.Timeout do
  @enforce_keys [:channel, :duration, :user, :user_id, :room_id, :tags]
  defstruct [:channel, :duration, :user, :user_id, :room_id, :tags]
end
