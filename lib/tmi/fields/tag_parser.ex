defmodule TMI.Fields.TagParser do
  @moduledoc """
  Parse Twitch IRC tag strings.
  """
  import NimbleParsec

  alias TMI.Fields

  require Logger

  @doc """
  Parses tags.

  ## Examples

      iex> tags = "@badge-info=subscriber/47;badges=broadcaster/1,subscriber/0,sub-gifter/1;color=#5DA5D9;display-name=ShyRyan"
      iex> TagParser.parse(tags)
      {:ok,
        %{
          color: "#5DA5D9",
          badge_info: [{"subscriber", 47}],
          badges: [{"broadcaster", 1}, {"subscriber", 0}, {"sub-gifter", 1}],
          display_name: "ShyRyan"
        }}

  """
  def parse(tag_string) do
    case parse_tags(tag_string) do
      {:ok, tags, "", _, _, _} -> {:ok, Map.new(tags)}
      {:ok, _parsed, rest, _, _, _} -> {:error, "unparsed content", rest}
      {:error, reason, context, _, _, _} -> {:error, reason, context}
    end
  end

  def parse!(tag_string) do
    case parse(tag_string) do
      {:ok, tags} -> tags
      {:error, reason, _context} -> raise reason
    end
  end

  @supported_tags Fields.supported_tags()

  # Valid ascii chars in tag keys and values. This is including all printable
  # characters (33-126), plus `\s` (32), and excluding `=` (59) and `;` (61),
  # since these are special cases in the tag string.
  @valid_chars [32..58, 60, 62..126]

  tags =
    ascii_string(@valid_chars, min: 1)
    |> ignore(ascii_char([?=]))
    |> optional(ascii_string(@valid_chars, min: 1))
    |> optional(ignore(ascii_char([?;])))
    |> post_traverse({:tag_map, []})
    |> times(min: 1)

  defparsecp :parse_tags, ignore(ascii_char([?@])) |> concat(tags), inline: true

  defp tag_map(rest, [val, key], context, _line, _offset) do
    {rest, [tag_map({key, val})], context}
  end

  defp tag_map(rest, [key], context, _line, _offset) do
    {rest, [tag_map({key, nil})], context}
  end

  # This `tag_map/1` function does a lot of tag value parsing with `String` and
  # `Enum` functions but would, ideally, also be handled with parser
  # combinators. However, I do not know if this is practical. For now, I'm
  # doing it like this and would like to consider more parser combinators in
  # the future.

  defp tag_map({"badge-info" = key, val}) do
    info =
      val
      |> String.split(",")
      |> Enum.map(fn item ->
        [badge, n] = String.split(item, "/")
        {badge, String.to_integer(n)}
      end)

    {tag_name(key), info}
  end

  defp tag_map({"badges" = key, val}) do
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

  defp tag_map({"emotes" = key, nil}), do: {tag_name(key), []}

  defp tag_map({"emotes" = key, val}) do
    emotes =
      val
      |> String.split(val, ",")
      |> Enum.map(fn str ->
        [emote, range] = String.split(str, ":")
        [start, stop] = String.split(range, "-")
        {emote, start, stop}
      end)

    {tag_name(key), emotes}
  end

  defp tag_map({"flags" = key, val}) do
    {tag_name(key), val || []}
  end

  defp tag_map({"system-msg" = key, val}) do
    {tag_name(key), String.replace(val, "\\s", " ")}
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

  defp tag_map({"user-type" = key, val}) do
    type =
      case val do
        nil -> :normal
        "admin" -> :admin
        "global_mod" -> :global_mod
        "staff" -> :staff
      end

    {tag_name(key), type}
  end

  defp tag_map({"msg-param-should-share-streak" = key, val}) do
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

  defp tag_map({"tmi-sent-ts" = key, val}) do
    timestamp = String.to_integer(val) |> DateTime.from_unix!(:millisecond)
    {tag_name(key), timestamp}
  end

  defp tag_map({key, val}) when key in @supported_tags do
    {tag_name(key), val}
  end

  defp tag_map(tag) do
    # We want to log unsupported tags so we know which ones we need to
    # add support for in the future.
    Logger.warning("""
    [TMI.TagParser] You found an unsupported tag: `#{inspect(tag)}`
    [TMI.TagParser] Please report it as an issue at: <https://github.com/ryanwinchester/tmi.ex>
    """)

    tag
  end

  # Takes the tag name from Twitch and maps it to our own TMI name.
  defp tag_name(key), do: Fields.field_from_tag!(key)
end
