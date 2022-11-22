defmodule TMI.Events.Primepaidupgrade do
  @enforce_keys [:channel, :user, :plan, :plan_name, :tags]
  defstruct [:channel, :user, :plan, :plan_name, :tags]
end
