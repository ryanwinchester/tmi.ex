defmodule TMITest do
  use ExUnit.Case, async: true

  doctest TMI, import: true

  @chat_data_path Path.expand("support/data/irc/messages", __DIR__)
  @chat_message_files File.ls!(@chat_data_path)

  @eventsub_data_path Path.expand("support/data/eventsub", __DIR__)
  @eventsub_message_files File.ls!(@eventsub_data_path)

  defmodule TestBot do
    use TMI
  end

  describe "chat" do
    # Generate a bunch of tests for every batch of messages in the messages test
    # data files. This just makes sure we don't have any breaking changes in our
    # tag and event parsing.
    for file <- @chat_message_files do
      test "#{file}" do
        {messages, []} = Code.eval_file(unquote(file), @chat_data_path)

        for message <- messages do
          assert TMI.apply_incoming_to_bot(message, TestBot)
        end
      end
    end
  end

  describe "eventsub" do
    # Generate a bunch of tests for every batch of messages in the messages test
    # data files. This just makes sure we don't have any breaking changes in our
    # tag and event parsing.
    for file <- @eventsub_message_files do
      test "#{file}" do
        {messages, []} = Code.eval_file(unquote(file), @eventsub_data_path)

        for message <- messages do
          %{"subscription" => %{"type" => type}, "event" => payload} = message
          assert _event = TMI.EventSub.Events.from_payload(type, payload)
        end
      end
    end
  end
end
