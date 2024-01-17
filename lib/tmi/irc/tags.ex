defmodule TMI.IRC.Tags do
  @moduledoc """
  Parse Twitch IRC tag strings.
  """

  alias TMI.IRC.Parsing.EventMapping
  alias TMI.IRC.Parsing.TagMapping

  require Logger

  @supported_tags TagMapping.supported_tags()

  @doc """
  Decode a tag value according to
  [IRCv3](https://ircv3.net/specs/extensions/message-tags.html) message tags.

  ## Examples

      iex> Tags.decode("hello\\schat")
      "hello chat"

  """
  def decode(nil), do: nil
  def decode(value), do: decode(value, <<>>)

  defp decode(<<"\\:", rest::binary>>, acc), do: decode(rest, [acc | ";"])
  defp decode(<<"\\s", rest::binary>>, acc), do: decode(rest, [acc | " "])
  defp decode(<<"\\\\", rest::binary>>, acc), do: decode(rest, [acc | "\\"])
  defp decode(<<c::binary-1, rest::binary>>, acc), do: decode(rest, [acc | c])
  defp decode(<<>>, acc), do: IO.iodata_to_binary(acc)

  @doc """
  Parses tags.

  ## Examples

      iex> tags = "@badge-info=subscriber/47;badges=broadcaster/1,subscriber/0,sub-gifter/1;color=#5DA5D9;display-name=ShyRyan"
      iex> Tags.parse!(tags)
      %{
        color: "#5DA5D9",
        badge_info: [{"subscriber", 47}],
        badges: [{"broadcaster", 1}, {"subscriber", 0}, {"sub-gifter", 1}],
        display_name: "ShyRyan"
      }

  """
  def parse!("@" <> tag_string) do
    tag_string
    |> :binary.split(";", [:global])
    |> Enum.map(fn tag ->
      case :binary.split(tag, "=") do
        [key, ""] -> tag_map({key, nil})
        [key, val] -> tag_map({key, val})
      end
    end)
    |> Map.new()
  end

  defp tag_map({"badge-info" = key, val}) when is_binary(val) do
    info =
      val
      |> String.split(",")
      |> Enum.map(fn item ->
        [badge, n] = String.split(item, "/")
        {badge, String.to_integer(n)}
      end)

    {tag_name(key), info}
  end

  defp tag_map({"badges" = key, val}) when is_binary(val) do
    info =
      val
      |> String.split(",")
      |> Enum.map(fn item ->
        [badge, n] = String.split(item, "/")
        {badge, String.to_integer(n)}
      end)

    {tag_name(key), info}
  end

  defp tag_map({"msg-param-sub-plan" = key, val}) do
    plan =
      case val do
        "1000" -> :t1
        "2000" -> :t2
        "3000" -> :t3
        "Prime" -> :prime
      end

    {tag_name(key), plan}
  end

  defp tag_map({"msg-param-category" = key, val}) do
    milestone =
      case val do
        "watch-streak" ->
          :watch_streak

        milestone ->
          Logger.warning("""
          [TMI.Fields.TagParser] You found an unsupported milestone: `#{inspect(milestone)}`
          Please report it as an issue at: <https://github.com/ryanwinchester/tmi.ex>
          """)

          {:unknown, milestone}
      end

    {tag_name(key), milestone}
  end

  defp tag_map({"emotes" = key, nil}), do: {tag_name(key), []}

  defp tag_map({"emotes" = key, val}) do
    emotes =
      val
      |> String.split("/")
      |> Enum.map(fn str ->
        [emote, ranges] = String.split(str, ":")

        ranges =
          String.split(ranges, ",")
          |> Enum.map(fn range ->
            [start, stop] = String.split(range, "-")
            String.to_integer(start)..String.to_integer(stop)
          end)

        {emote, ranges}
      end)

    {tag_name(key), emotes}
  end

  defp tag_map({"msg-id" = key, val}) do
    {tag_name(key), EventMapping.event_name!(val)}
  end

  defp tag_map({"flags" = key, val}) do
    {tag_name(key), val || []}
  end

  defp tag_map({"system-msg" = key, val}) do
    {tag_name(key), decode(val)}
  end

  defp tag_map({"msg-param-value" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"ban-duration" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"bits" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"msg-param-threshold" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"msg-param-mass-gift-count" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"msg-param-gift-months" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"msg-param-months" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"msg-param-sender-count" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"msg-param-viewerCount" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"msg-param-promo-gift-total" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"msg-param-streak-months" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"msg-param-cumulative-months" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"msg-param-multimonth-duration" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"msg-param-multimonth-tenure" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"slow" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"user-type" = key, val}) do
    type =
      case val do
        nil -> :normal
        "mod" -> :mod
        "admin" -> :admin
        "global_mod" -> :global_mod
        "staff" -> :staff
        type -> {:unknown, type}
      end

    {tag_name(key), type}
  end

  defp tag_map({"msg-param-goal-contribution-type" = key, val}) do
    type =
      case val do
        "SUBS" -> :subs
        "FOLLOWERS" -> :followers
      end

    {tag_name(key), type}
  end

  defp tag_map({"msg-param-goal-current-contributions" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"msg-param-goal-target-contributions" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"msg-param-goal-user-contributions" = key, val}) do
    {tag_name(key), String.to_integer(val)}
  end

  defp tag_map({"msg-param-should-share-streak" = key, val}) do
    {tag_name(key), val == "1"}
  end

  defp tag_map({"first-msg" = key, val}) do
    {tag_name(key), val == "1"}
  end

  defp tag_map({"returning-chatter" = key, val}) do
    {tag_name(key), val == "1"}
  end

  defp tag_map({"subscriber" = key, val}) do
    {tag_name(key), val == "1"}
  end

  defp tag_map({"mod" = key, val}) do
    {tag_name(key), val == "1"}
  end

  defp tag_map({"turbo" = key, val}) do
    {tag_name(key), val == "1"}
  end

  defp tag_map({"vip" = key, val}) do
    {tag_name(key), val == "1"}
  end

  defp tag_map({"emote-only" = key, val}) do
    {tag_name(key), val == "1"}
  end

  defp tag_map({"followers-only" = key, val}) do
    {tag_name(key), val == "1"}
  end

  defp tag_map({"subs-only" = key, val}) do
    {tag_name(key), val == "1"}
  end

  defp tag_map({"r9k" = key, val}) do
    {tag_name(key), val == "1"}
  end

  defp tag_map({"msg-param-prior-gifter-anonymous" = key, val}) do
    {tag_name(key), val == "true"}
  end

  defp tag_map({"msg-param-was-gifted" = key, val}) do
    {tag_name(key), val == "true"}
  end

  defp tag_map({"tmi-sent-ts" = key, val}) do
    timestamp = String.to_integer(val) |> DateTime.from_unix!(:millisecond)
    {tag_name(key), timestamp}
  end

  defp tag_map({"reply-parent-msg-body" = key, val}) do
    {tag_name(key), decode(val)}
  end

  defp tag_map({key, val}) when key in @supported_tags do
    {tag_name(key), decode(val)}
  end

  defp tag_map(tag) do
    # We want to log unsupported tags so we know which ones we need to
    # add support for in the future.
    Logger.warning("""
    [TMI.IRC.Tags] You found an unsupported tag: `#{inspect(tag)}`
    Please report it as an issue at: <https://github.com/ryanwinchester/tmi.ex>
    """)

    tag
  end

  # Takes the tag name from Twitch and maps it to our own TMI name.
  defp tag_name(key), do: TagMapping.field_from_tag!(key)
end
