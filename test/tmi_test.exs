defmodule TMITest do
  use ExUnit.Case, async: true

  doctest TMI, import: true

  @data_path Path.expand("support/data/irc/messages", __DIR__)
  @message_files File.ls!(@data_path)

  defmodule TestBot do
    use TMI
  end

  # Generate a bunch of tests for every batch of messages in the messages test
  # data files. This just makes sure we don't have any breaking changes in our
  # tag and event parsing.
  for file <- @message_files do
    test "#{file}" do
      {messages, []} = Code.eval_file(unquote(file), @data_path)

      for message <- messages do
        assert TMI.apply_incoming_to_bot(message, TestBot)
      end
    end
  end
end
