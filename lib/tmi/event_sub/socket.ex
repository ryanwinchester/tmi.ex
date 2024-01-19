defmodule TMI.EventSub.Socket do
  @moduledoc false
  use WebSockex

  require Logger

  alias TMI.Twitch.Client

  @default_url "wss://eventsub.wss.twitch.tv/ws"

  @default_keepalive_timeout 30

  @required_opts ~w[user_id client_id access_token handler]a
  @allowed_opts @required_opts ++ ~w[subscriptions]

  @default_subs ~w[
    channel.ad_break.begin channel.cheer channel.follow channel.subscription.end
    channel.channel_points_custom_reward_redemption.add
    channel.channel_points_custom_reward_redemption.update
    channel.charity_campaign.donate channel.charity_campaign.progress
    channel.goal.begin channel.goal.progress channel.goal.end
    channel.hype_train.begin channel.hype_train.progress channel.hype_train.end
    channel.shoutout.create channel.shoutout.receive
    stream.online stream.offline
  ]

  # TODO: `extension.bits_transaction.create` requires extension_client_id

  @doc """
  Starts the connection to the EventSub WebSocket server.

  ## Options

   * `:client_id` - Twitch app client id.
   * `:access_token` - Twitch app access token with required scopes for the
      provided `:subscriptions`.
   * `:subscriptions` - The subscriptions for EventSub.
   * `:url` - A websocket URL to connect to. `Defaults to "wss://eventsub.wss.twitch.tv/ws"`.
   * `:keepalive_timeout` - The keepalive timeout in seconds. Specifying an invalid,
      but numeric value will return the nearest acceptable value. Defaults to `10`.
   * `:start?` - A boolean value of whether or not to start the eventsub socket.

  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    if Keyword.get(opts, :start?, true) do
      do_start(opts)
    else
      :ignore
    end
  end

  defp do_start(opts) do
    Logger.info("[TMI.EventSub.Socket] connecting...")

    if not Enum.all?(@required_opts, &Keyword.has_key?(opts, &1)) do
      raise ArgumentError,
        message: "missing one of the required options, got: #{inspect(Keyword.keys(opts))}"
    end

    keepalive = Keyword.get(opts, :keepalive_timeout, @default_keepalive_timeout)
    query = URI.encode_query(keepalive_timeout_seconds: keepalive)

    url =
      opts
      |> Keyword.get(:url, @default_url)
      |> URI.parse()
      |> URI.append_query(query)
      |> URI.to_string()

    state =
      opts
      |> Keyword.take(@allowed_opts)
      |> Keyword.merge(url: url)
      |> Map.new()

    WebSockex.start_link(url, __MODULE__, state)
  end

  # ----------------------------------------------------------------------------
  # Callbacks
  # ----------------------------------------------------------------------------

  @impl WebSockex
  def handle_frame({:text, msg}, state) do
    case Jason.decode(msg) do
      {:ok, %{"metadata" => metadata, "payload" => payload}} ->
        handle_message(metadata, payload, state)
        {:ok, state}

      _ ->
        Logger.warning("[TMI.EventSub.Socket] Unhandled message: #{msg}")
        {:ok, state}
    end
  end

  @impl WebSockex
  def handle_frame({type, msg}, state) do
    Logger.debug(
      "[TMI.EventSub.Socket] unhandled message type: #{inspect(type)}, msg: #{inspect(msg)}"
    )

    {:ok, state}
  end

  @impl WebSockex
  def handle_cast({:send, {type, msg} = frame}, state) do
    Logger.debug("[TMI.EventSub.Socket] sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  # ----------------------------------------------------------------------------
  # Helpers
  # ----------------------------------------------------------------------------

  # ## Welcome message
  #
  # When you connect, Twitch replies with a welcome message.
  # The `message_type` field is set to `session_welcome`. This message contains
  # the WebSocket session’s ID that you use when subscribing to events.
  #
  # **IMPORTANT** By default, you have 10 seconds from the time you receive
  # the Welcome message to subscribe to an event, unless otherwise specified
  # when connecting. If you don’t subscribe within this timeframe, the
  # server closes the connection.
  #
  #     {
  #       "metadata": {
  #         "message_id": "96a3f3b5-5dec-4eed-908e-e11ee657416c",
  #         "message_type": "session_welcome",
  #         "message_timestamp": "2023-07-19T14:56:51.634234626Z"
  #       },
  #       "payload": {
  #         "session": {
  #           "id": "AQoQILE98gtqShGmLD7AM6yJThAB",
  #           "status": "connected",
  #           "connected_at": "2023-07-19T14:56:51.616329898Z",
  #           "keepalive_timeout_seconds": 10,
  #           "reconnect_url": null
  #         }
  #       }
  #     }
  #
  defp handle_message(%{"message_type" => "session_welcome"}, payload, state) do
    Logger.info("[TMI.EventSub.Socket] connected")

    session_id = get_in(payload, ["session", "id"])
    client_id = state.client_id
    user_id = state.user_id
    access_token = state.access_token
    subscriptions = Map.get(state, :subscriptions, @default_subs)

    # TODO: Supervised task anyone?
    Enum.each(subscriptions, fn type ->
      Client.create_subscription(type, user_id, session_id, client_id, access_token)
    end)
  end

  # ## Keepalive message
  #
  # The keepalive messages indicate that the WebSocket connection is healthy.
  # The server sends this message if Twitch doesn’t deliver an event
  # notification within the keepalive_timeout_seconds window specified in
  # the Welcome message.
  #
  # If your client doesn’t receive an event or keepalive message for longer
  # than keepalive_timeout_seconds, you should assume the connection is lost
  # and reconnect to the server and resubscribe to the events. The keepalive
  # timer is reset with each notification or keepalive message.
  #
  #     {
  #         "metadata": {
  #             "message_id": "84c1e79a-2a4b-4c13-ba0b-4312293e9308",
  #             "message_type": "session_keepalive",
  #             "message_timestamp": "2023-07-19T10:11:12.634234626Z"
  #         },
  #         "payload": {}
  #     }
  #
  defp handle_message(%{"message_type" => "session_keepalive"}, _payload, _state) do
    Logger.info("[TMI.EventSub.Socket] keepalive")
  end

  # ## Notification message
  #
  # A notification message is sent when an event that you subscribe to occurs.
  # The message contains the event’s details.
  #
  #     {
  #         "metadata": {
  #             "message_id": "befa7b53-d79d-478f-86b9-120f112b044e",
  #             "message_type": "notification",
  #             "message_timestamp": "2022-11-16T10:11:12.464757833Z",
  #             "subscription_type": "channel.follow",
  #             "subscription_version": "1"
  #         },
  #         "payload": {
  #             "subscription": {
  #                 "id": "f1c2a387-161a-49f9-a165-0f21d7a4e1c4",
  #                 "status": "enabled",
  #                 "type": "channel.follow",
  #                 "version": "1",
  #                 "cost": 1,
  #                 "condition": {
  #                     "broadcaster_user_id": "12826"
  #                 },
  #                 "transport": {
  #                     "method": "websocket",
  #                     "session_id": "AQoQexAWVYKSTIu4ec_2VAxyuhAB"
  #                 },
  #                 "created_at": "2022-11-16T10:11:12.464757833Z"
  #             },
  #             "event": {
  #                 "user_id": "1337",
  #                 "user_login": "awesome_user",
  #                 "user_name": "Awesome_User",
  #                 "broadcaster_user_id": "12826",
  #                 "broadcaster_user_login": "twitch",
  #                 "broadcaster_user_name": "Twitch",
  #                 "followed_at": "2023-07-15T18:16:11.17106713Z"
  #             }
  #         }
  #     }
  #
  defp handle_message(
         %{"message_type" => "notification", "subscription_type" => type},
         %{"event" => payload},
         state
       ) do
    Logger.debug("[TMI.EventSub.Socket] got notification: " <> inspect(payload, pretty: true))

    type
    |> TMI.EventSub.Events.from_payload(payload)
    |> state.handler.handle_event()
  end

  # ## Reconnect message
  #
  # A reconnect message is sent if the edge server that the client is connected
  # to needs to be swapped. This message is sent 30 seconds prior to closing the
  # connection, specifying a new URL for the client to connect to. Following the
  # reconnect flow will ensure no messages are dropped in the process.
  #
  # The message includes a URL in the `reconnect_url` field that you should
  # immediately use to create a new connection. The connection will include the
  # same subscriptions that the old connection had. You should not close the old
  # connection until you receive a Welcome message on the new connection.
  #
  # **NOTE** Use the reconnect URL as is; do not modify it.
  #
  # The old connection receives events up until you connect to the new URL and
  # receive the welcome message to ensure an uninterrupted flow of notifications.
  #
  # **NOTE** Twitch sends the old connection a close frame with code `4004` if
  # you connect to the new socket but never disconnect from the old socket or
  # you don’t connect to the new socket within the specified timeframe.
  #
  #     {
  #         "metadata": {
  #             "message_id": "84c1e79a-2a4b-4c13-ba0b-4312293e9308",
  #             "message_type": "session_reconnect",
  #             "message_timestamp": "2022-11-18T09:10:11.634234626Z"
  #         },
  #         "payload": {
  #             "session": {
  #               "id": "AQoQexAWVYKSTIu4ec_2VAxyuhAB",
  #               "status": "reconnecting",
  #               "keepalive_timeout_seconds": null,
  #               "reconnect_url": "wss://eventsub.wss.twitch.tv?...",
  #               "connected_at": "2022-11-16T10:11:12.634234626Z"
  #             }
  #         }
  #     }
  #
  defp handle_message(%{"message_type" => "session_reconnect"}, _payload, _state) do
    Logger.debug("[TMI.EventSub.Socket] reconnect message")
  end

  # ## Revocation message
  #
  # A revocation message is sent if Twitch revokes a subscription. The
  # `subscription` object’s `type` field identifies the subscription that was
  # revoked, and the `status` field identifies the reason why the subscription was
  # revoked. Twitch revokes your subscription in the following cases:
  #
  #  - The user mentioned in the subscription no longer exists. The
  #    notification’s `status` field is set to user_removed.
  #  - The user revoked the authorization token that the subscription relied on.
  #    The notification’s `status` field is set to `authorization_revoked`.
  #  - The subscribed to subscription type and version is no longer supported.
  #    The notification’s `status` field is set to `version_removed`.
  #
  # You’ll receive this message once and then no longer receive messages for the
  # specified user and subscription type.
  #
  # Twitch reserves the right to revoke a subscription at any time.
  #
  #     {
  #         "metadata": {
  #             "message_id": "84c1e79a-2a4b-4c13-ba0b-4312293e9308",
  #             "message_type": "revocation",
  #             "message_timestamp": "2022-11-16T10:11:12.464757833Z",
  #             "subscription_type": "channel.follow",
  #             "subscription_version": "1"
  #         },
  #         "payload": {
  #             "subscription": {
  #                 "id": "f1c2a387-161a-49f9-a165-0f21d7a4e1c4",
  #                 "status": "authorization_revoked",
  #                 "type": "channel.follow",
  #                 "version": "1",
  #                 "cost": 1,
  #                 "condition": {
  #                     "broadcaster_user_id": "12826"
  #                 },
  #                 "transport": {
  #                     "method": "websocket",
  #                     "session_id": "AQoQexAWVYKSTIu4ec_2VAxyuhAB"
  #                 },
  #                 "created_at": "2022-11-16T10:11:12.464757833Z"
  #             }
  #         }
  #     }
  #
  defp handle_message(%{"message_type" => "revocation"}, payload, _state) do
    Logger.error("[TMI.EventSub.Socket] sub revoked: #{inspect(payload)}")
  end

  # ## Close message
  #
  # Twitch sends a Close frame when it closes the connection. The following table lists the reasons for closing the connection.
  #
  # Code 	Reason 	Notes
  # 4000 	Internal server error 	Indicates a problem with the server (similar to an HTTP 500 status code).
  # 4001 	Client sent inbound traffic 	Sending outgoing messages to the server is prohibited with the exception of pong messages.
  # 4002 	Client failed ping-pong 	You must respond to ping messages with a pong message. See Ping message.
  # 4003 	Connection unused 	When you connect to the server, you must create a subscription within 10 seconds or the connection is closed. The time limit is subject to change.
  # 4004 	Reconnect grace time expired 	When you receive a session_reconnect message, you have 30 seconds to reconnect to the server and close the old connection. See Reconnect message.
  # 4005 	Network timeout 	Transient network timeout.
  # 4006 	Network error 	Transient network error.
  # 4007 	Invalid reconnect 	The reconnect URL is invalid.
  #
  defp handle_message(_metadata, payload, _state) do
    # TODO: match ^
    Logger.error("[TMI.EventSub.Socket] closed: #{inspect(payload)}")
  end
end
