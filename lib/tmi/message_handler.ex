defmodule TMI.MessageHandler do
  @moduledoc """
  Translates ExIRC messages to TMI bot messages.
  """

  def handle_message({:connected, server, port}, bot) do
    apply(bot, :handle_connected, [server, port])
  end

  def handle_message(:logged_in, bot) do
    apply(bot, :handle_logged_in, [])
  end

  def handle_message({:login_failed, reason}, bot) do
    apply(bot, :handle_login_failed, [reason])
  end

  def handle_message(:disconnected, bot) do
    apply(bot, :handle_disconnected, [])
  end

  def handle_message({:joined, channel}, bot) do
    apply(bot, :handle_join, [channel])
  end

  def handle_message({:joined, channel, user}, bot) do
    apply(bot, :handle_join, [channel, user.user])
  end

  def handle_message({:parted, channel, user}, bot) do
    apply(bot, :handle_part, [channel, user.user])
  end

  def handle_message({:kicked, user, channel}, bot) do
    apply(bot, :handle_kick, [channel, user.user])
  end

  def handle_message({:kicked, user, kicker, channel}, bot) do
    apply(bot, :handle_kick, [channel, user.user, kicker.user])
  end

  def handle_message({:received, message, sender}, bot) do
    apply(bot, :handle_whisper, [message, sender.user])
  end

  def handle_message({:received, message, sender, channel}, bot) do
    apply(bot, :handle_message, [message, sender.user, channel])
  end

  def handle_message({:mentioned, message, sender, channel}, bot) do
    apply(bot, :handle_mention, [message, sender.user, channel])
  end

  def handle_message({:me, message, sender, channel}, bot) do
    apply(bot, :handle_action, [message, sender.user, channel])
  end

  def handle_message(msg, bot) do
    apply(bot, :handle_unrecognized, [msg])
  end
end
