defmodule TMI.EventSub.Events do
  require Logger

  @events %{
    "channel.follow" => TMI.Events.Follow,
    "channel.shoutout.create" => TMI.Events.ShoutoutCreate,
    "channel.shoutout.receive" => TMI.Events.ShoutoutReceive
  }

  @doc """
  Take a payload and return a `TMI.Event` struct.

  ## Examples

      iex> payload = %{
      ...>   "broadcaster_user_id" => "146616692",
      ...>   "broadcaster_user_login" => "ryanwinchester_",
      ...>   "broadcaster_user_name" => "RyanWinchester_",
      ...>   "followed_at" => "2024-01-19T03:32:41.640955348Z",
      ...>   "user_id" => "589368619",
      ...>   "user_login" => "foobar",
      ...>   "user_name" => "FooBar"
      ...> }
      iex> from_payload("channel.follow", payload)
      %TMI.Events.Follow{
        broadcaster_user_id: "146616692",
        broadcaster_user_login: "ryanwinchester_",
        broadcaster_user_name: "RyanWinchester_",
        followed_at: ~U[2024-01-19 03:32:41.640955Z],
        user_id: "589368619",
        user_login: "foobar",
        user_name: "FooBar"
      }

  """
  @spec from_payload(String.t(), map()) :: TMI.Event.event()
  def from_payload(event_type, payload)

  for {event, module} <- @events do
    def from_payload(unquote(event), payload) do
      payload
      |> Enum.map(&payload_map/1)
      |> then(&struct(unquote(module), &1))
    end
  end

  # TODO: Map the field names similar to in the IRC client.
  # e.g. from "broadcaster_user_name" to :broadcaster_display_name.

  defp payload_map({"followed_at", val}) do
    followed_at =
      case DateTime.from_iso8601(val) do
        {:ok, dt, 0} -> dt
        {:ok, _dt, offset} -> raise "unexpected offset (#{offset}) parsing #{val}"
        _bad -> raise "Bad datetime #{val}"
      end

    {:followed_at, followed_at}
  end

  # TODO: For now, use to_atom, because Modules aren't loaded during dev
  # until used.
  defp payload_map({field, val}), do: {String.to_atom(field), val}

  # defp payload_map({field, val}) do
  #   try do
  #     {String.to_atom(field), val}
  #   rescue
  #     ArgumentError ->
  #       Logger.warning("""
  #       You have found an unexpected field: #{inspect({field, val})}.
  #       Please open an issue at <https://github.com/ryanwinchester/tmi.ex>
  #       """)

  #       {field, val}
  #   end
  # end
end
