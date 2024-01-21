defmodule TMI.EventSub.Events.Unrecognized do
  @moduledoc false
  use TMI.Event,
    fields: [
      :msg
    ]
end
