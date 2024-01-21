defmodule TMI.Twitch.Client do
  @moduledoc """
  Twitch API.
  """

  require Logger

  @base_url "https://api.twitch.tv/helix"
  # @base_url "http://127.0.0.1:8080"

  @subscriptions %{
    "channel.update" => 2,
    "channel.follow" => 2,
    "channel.ad_break.begin" => 1,
    "channel.chat.clear" => 1,
    "channel.chat.clear_user_messages" => 1,
    "channel.chat.message_delete" => 1,
    "channel.chat.notification" => 1,
    "channel.chat_settings.update" => "beta",
    "channel.subscribe" => 1,
    "channel.subscription.end" => 1,
    "channel.subscription.gift" => 1,
    "channel.subscription.message" => 1,
    "channel.cheer" => 1,
    "channel.raid" => 1,
    "channel.ban" => 1,
    "channel.unban" => 1,
    "channel.moderator.add" => 1,
    "channel.moderator.remove" => 1,
    "channel.guest_star_session.begin" => "beta",
    "channel.guest_star_session.end" => "beta",
    "channel.guest_star_guest.update" => "beta",
    "channel.guest_star_settings.update" => "beta",
    "channel.channel_points_custom_reward.add" => 1,
    "channel.channel_points_custom_reward.update" => 1,
    "channel.channel_points_custom_reward.remove" => 1,
    "channel.channel_points_custom_reward_redemption.add" => 1,
    "channel.channel_points_custom_reward_redemption.update" => 1,
    "channel.poll.begin" => 1,
    "channel.poll.progress" => 1,
    "channel.poll.end" => 1,
    "channel.prediction.begin" => 1,
    "channel.prediction.progress" => 1,
    "channel.prediction.lock" => 1,
    "channel.prediction.end" => 1,
    "channel.charity_campaign.donate" => 1,
    "channel.charity_campaign.start" => 1,
    "channel.charity_campaign.progress" => 1,
    "channel.charity_campaign.stop" => 1,
    "drop.entitlement.grant" => 1,
    "extension.bits_transaction.create" => 1,
    "channel.goal.begin" => 1,
    "channel.goal.progress" => 1,
    "channel.goal.end" => 1,
    "channel.hype_train.begin" => 1,
    "channel.hype_train.progress" => 1,
    "channel.hype_train.end" => 1,
    "channel.shield_mode.begin" => 1,
    "channel.shield_mode.end" => 1,
    "channel.shoutout.create" => 1,
    "channel.shoutout.receive" => 1,
    "stream.online" => 1,
    "stream.offline" => 1,
    "user.authorization.grant" => 1,
    "user.authorization.revoke" => 1,
    "user.update" => 1
  }

  @subscription_types Map.keys(@subscriptions)

  @doc """
  List all of the available subscription types.
  """
  def subscription_types, do: @subscription_types

  @doc """
  `Req` request (client?) for Twitch API requests.
  """
  def client(client_id, access_token) do
    headers =
      %{
        "client-id" => client_id,
        "content-type" => "application/json"
      }

    auth = access_token && {:bearer, access_token}

    Req.new(base_url: @base_url, headers: headers, auth: auth)
  end

  @doc """
  Revoke an access token.
  """
  def revoke_token!(client_id, token) do
    params = [client_id: client_id, token: token]
    Req.post!("https://id.twitch.tv/oauth2/revoke", form: params)
  end

  @doc """
  Create an eventsub subscription using websockets.
  See: https://dev.twitch.tv/docs/api/reference/#create-eventsub-subscription
  """
  def create_subscription(type, user_id, session_id, client_id, access_token)
      when type in @subscription_types do
    params = %{
      "type" => type,
      "version" => Map.fetch!(@subscriptions, type),
      "condition" => condition(type, user_id),
      "transport" => %{
        "method" => "websocket",
        "session_id" => session_id
      }
    }

    resp =
      client(client_id, access_token)
      |> Req.post(url: "/eventsub/subscriptions", json: params)

    case resp do
      {:ok, %{status: 202, headers: _headers, body: body}} ->
        Logger.debug("[TMI.Twitch.Client] #{type} subscription created:\n#{inspect(body)}")
        {:ok, body}

      {:ok, %{status: 429, headers: %{"ratelimit-reset" => resets_at}}} ->
        Logger.warning("[TMI.Twitch] rate-limited; resets at #{resets_at}")
        {:error, resp}

      {:ok, %{status: _status} = resp} ->
        Logger.error("[TMI.Twitch] unexpected response: #{inspect(resp)}")
        {:error, resp}

      {:error, error} ->
        Logger.error("[TMI.Twitch] error making resquest: #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  List all eventsub subscriptions.
  """
  def list_subscriptions(client_id, access_token, params \\ %{}) do
    resp =
      client(client_id, access_token)
      |> Req.get(url: "/eventsub/subscriptions", json: params)

    case resp do
      {:ok, %{status: 200, headers: _headers, body: body}} ->
        {:ok, body}

      {:ok, %{status: 429, headers: %{"ratelimit-reset" => resets_at}}} ->
        Logger.warning("[TMI.Twitch] rate-limited; resets at #{resets_at}")
        {:error, resp}

      {:ok, %{status: _status} = resp} ->
        Logger.error("[TMI.Twitch] unexpected response: #{inspect(resp)}")
        {:error, resp}

      {:error, error} ->
        Logger.error("[TMI.Twitch] error making resquest: #{inspect(error)}")
        {:error, error}
    end
  end

  ## Different subscription types require different conditions.

  defp condition("channel.chat.notification", user_id) do
    %{
      "broadcaster_user_id" => user_id,
      "user_id" => user_id
    }
  end

  defp condition("channel.raid", user_id) do
    %{
      "to_broadcaster_user_id" => user_id
    }
  end

  defp condition("channel.follow" <> _, user_id) do
    %{
      "broadcaster_user_id" => user_id,
      "moderator_user_id" => user_id
    }
  end

  defp condition("channel.shoutout" <> _, user_id) do
    %{
      "broadcaster_user_id" => user_id,
      "moderator_user_id" => user_id
    }
  end

  defp condition(_type, user_id) do
    %{
      "broadcaster_user_id" => user_id
    }
  end
end
