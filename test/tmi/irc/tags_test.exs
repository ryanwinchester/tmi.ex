defmodule TMI.IRC.TagsTest do
  use ExUnit.Case, async: true

  alias TMI.IRC.Tags

  doctest Tags

  describe "decode/1" do
    test "decodes escaped" do
      value = "raw+:=,escaped\\:\\s\\\\"
      expected = "raw+:=,escaped; \\"
      assert Tags.decode(value) == expected
    end
  end

  describe "parse!/1" do
    defp tagstrings(file) do
      "../../support/data/irc/tags"
      |> Path.expand(__DIR__)
      |> Path.join(file <> ".txt")
      |> File.read!()
      |> String.split()
    end

    test "communitypayforward" do
      for tagstring <- tagstrings("communitypayforward") do
        assert _tag = Tags.parse!(tagstring)
      end
    end
  end
end
