[
  %{
    "subscription" => %{
      "id" => "f1c2a387-161a-49f9-a165-0f21d7a4e1c4",
      "type" => "channel.ad_break.begin",
      "version" => "1",
      "status" => "enabled",
      "cost" => 0,
      "condition" => %{
        "broadcaster_user_id" => "1337"
      },
      "transport" => %{
        "method" => "webhook",
        "callback" => "https://example.com/webhooks/callback"
      },
      "created_at" => "2019-11-16T10:11:12.634234626Z"
    },
    "event" => %{
      "duration_seconds" => "60",
      "started_at" => "2019-11-16T10:11:12.634234626Z",
      "is_automatic" => "false",
      "broadcaster_user_id" => "1337",
      "broadcaster_user_login" => "cool_user",
      "broadcaster_user_name" => "Cool_User",
      "requester_user_id" => "1337",
      "requester_user_login" => "cool_user",
      "requester_user_name" => "Cool_User"
    }
  }
]
