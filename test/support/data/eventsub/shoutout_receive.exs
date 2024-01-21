[
  %{
    "subscription" => %{
      "id" => "f1c2a387-161a-49f9-a165-0f21d7a4e1c4",
      "type" => "channel.shoutout.receive",
      "version" => "1",
      "status" => "enabled",
      "cost" => 0,
      "condition" => %{
        "broadcaster_user_id" => "626262",
        "moderator_user_id" => "98765"
      },
      "transport" => %{
        "method" => "webhook",
        "callback" => "https://example.com/webhooks/callback"
      },
      "created_at" => "2022-07-25T10:11:12.1236739Z"
    },
    "event" => %{
      "broadcaster_user_id" => "626262",
      "broadcaster_user_name" => "SandySanderman",
      "broadcaster_user_login" => "sandysanderman",
      "from_broadcaster_user_id" => "12345",
      "from_broadcaster_user_name" => "SimplySimple",
      "from_broadcaster_user_login" => "simplysimple",
      "viewer_count" => 860,
      "started_at" => "2022-07-26T17:00:03.17106713Z"
    }
  }
]
