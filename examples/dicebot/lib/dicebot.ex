defmodule Dicebot do
  @moduledoc false
  use TMI

  require Logger

  @impl true
  def handle_message("!roll", sender, channel, _tags) do
    Logger.debug("[Dicebot.Bot] [#{channel}] #{sender} !rolls")
    roll = Enum.random(1..6)
    say(channel, "@#{sender} rolls a #{roll}!")
  end

  def handle_message(message, sender, channel, _tags) do
    Logger.debug("[Dicebot.Bot] [#{channel}] @#{sender} SAYS #{message}")
  end
end
