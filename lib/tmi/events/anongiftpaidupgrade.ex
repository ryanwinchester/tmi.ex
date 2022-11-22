defmodule TMI.Events.Anongiftpaidupgrade do
  @enforce_keys [:channel, :user, :tags]
  defstruct [:channel, :user, :tags]
end
