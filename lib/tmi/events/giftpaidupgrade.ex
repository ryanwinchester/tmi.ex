defmodule TMI.Events.Giftpaidupgrade do
  @enforce_keys [:channel, :user, :sender, :tags]
  defstruct [:channel, :user, :sender, :tags]
end
