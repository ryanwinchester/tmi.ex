defmodule TMI.Events.Messagedeleted do
  @enforce_keys [:channel, :user, :message, :message_id, :tags]
  defstruct [:channel, :user, :message, :message_id, :tags]
end
