[
  %{
    "subscription" => %{
      "id" => "f1c2a387-161a-49f9-a165-0f21d7a4e1c4",
      "type" => "channel.shoutout.create",
      "version" => "1",
      "status" => "enabled",
      "cost" => 0,
      "condition" => %{
        "broadcaster_user_id" => "12345",
        "moderator_user_id" => "98765"
      },
      "transport" => %{
        "method" => "webhook",
        "callback" => "https://example.com/webhooks/callback"
      },
      "created_at" => "2022-07-25T10:11:12.1236739Z"
    },
    "event" => %{
      "broadcaster_user_id" => "12345",
      "broadcaster_user_name" => "SimplySimple",
      "broadcaster_user_login" => "simplysimple",
      "moderator_user_id" => "98765",
      "moderator_user_name" => "ParticularlyParticular123",
      "moderator_user_login" => "particularlyparticular123",
      "to_broadcaster_user_id" => "626262",
      "to_broadcaster_user_name" => "SandySanderman",
      "to_broadcaster_user_login" => "sandysanderman",
      "started_at" => "2022-07-26T17:00:03.17106713Z",
      "viewer_count" => 860,
      "cooldown_ends_at" => "2022-07-26T17:02:03.17106713Z",
      "target_cooldown_ends_at" => "2022-07-26T18:00:03.17106713Z"
    }
  }
]
