defmodule TMI.Chat.Events.Unrecognized do
  @moduledoc false
  use TMI.Event,
    fields: [
      :msg
    ]
end
