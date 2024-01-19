# TMI (Twitch Messaging Interface) for Elixir

[![Hex.pm](https://img.shields.io/hexpm/v/tmi)](https://hex.pm/packages/tmi)
 [![Hex.pm](https://img.shields.io/hexpm/dt/tmi)](https://hex.pm/packages/tmi)
 [![Hex.pm](https://img.shields.io/hexpm/l/tmi)](https://github.com/ryanwinchester/tmi.ex/blob/main/LICENSE)

Connect to Twitch chat and EventSub with Elixir.

## Installation

The package can be installed by adding `tmi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tmi, "~> 0.6.0"},
  ]
end
```

Documentation can be found at [https://hexdocs.pm/tmi/readme.html](https://hexdocs.pm/tmi/readme.html).

## Usage

### Chat
You can use your own Twitch username, but it is recommended to make a new twitch account just for your bot.
You'll also need an OAuth token for the password.

 * The simplest method to get an OAuth token (while logged in to the account your bot will use), use
   the [Twitch Chat OAuth Password Generator](https://twitchapps.com/tmi/).

#### Config options (Chat/TMI)

 * `:bot` - A module that `use`s `TMI` and implements the `TMI.Handler` behaviour.
 * `:user` - Twitch username of your bot user (lowercase).
 * `:pass` - OAuth token to use as a password, prefixed with `oauth:`.
 * `:channels` - The list of channels to join (lowercase).
 * `:mod_channels` - The list of channels where your bot is a moderator
   (this effects the message and command rate limits).

```elixir
# config/runtime.exs

config :my_app,
  bots: [
    [
      bot: MyApp.MyBot,
      user: "myappbot",
      pass: System.fetch_env!("TWITCH_OATH_TOKEN"), # "oauth:myappbotpassword"
      channels: ["mychannel", "foo"],
      mod_channels: ["mychannel"],
      debug: false # defaults to false
    ]
  ]
```

### EventSub

 * You need to create an app on the [Twitch Developer Console](https://dev.twitch.tv/console/apps/create)
   to get the `client_id`. Also, add the redirect URL from the instructions in the token generator
   linked below if you use that.
 * To get an OAuth token for EventSub, it's easiest of you are logged in as the broadcaster of the
   channel you want to use the bot for and then you can use the [Twitch OAuth Token Generator](https://twitchapps.com/tokengen/)
   with the `client_id` of the app you created.

For scopes, I just use all the `read` scopes except for `whisper` and `stream_key`. If you want to
do the same, just paste the below into the `scopes` field on the token generator page:

```
analytics:read:extensions analytics:read:games bits:read channel:read:ads channel:read:charity channel:read:goals channel:read:guest_star channel:read:hype_train channel:read:polls channel:read:predictions channel:read:redemptions channel:read:subscriptions channel:read:vips moderation:read moderator:read:automod_settings moderator:read:blocked_terms moderator:read:chat_settings moderator:read:chatters moderator:read:followers moderator:read:guest_star moderator:read:shield_mode moderator:read:shoutouts user:read:blocked_users user:read:broadcast user:read:email user:read:follows user:read:subscriptions channel:bot chat:read user:bot user:read:chat
```

If you want to do moderation things with this token, then you can add the required scopes for
your actions found here [https://dev.twitch.tv/docs/authentication/scopes](https://dev.twitch.tv/docs/authentication/scopes/).

#### Config options (EventSub)

 * `:user_id` - The twitch user ID of the broadcaster.
 * `:handler` - A module that `use`s `TMI` and implements the `TMI.Handler` behaviour.
 * `:client_id` - The client ID of the application you used for the token.
 * `:access_token` - The OAuth token you generated with the correct scopes for your subscriptions.
 * `:keepalive_timeout` - Optional. The keepalive timeout in seconds. Specifying an invalid,
   but numeric value will return the nearest acceptable value. Defaults to `10`.
 * `:start?` - Optional. A boolean value of whether or not to start the eventsub socket.
   Defaults to `false` if there are no `event_sub` config options.
 * `:subscriptions` - Optional. The list of subscriptions to create. See below for more info.
   Defaults to:

```elixir
# Default subscriptions.
~w[
  channel.ad_break.begin channel.cheer channel.follow channel.subscription.end
  channel.channel_points_custom_reward_redemption.add
  channel.channel_points_custom_reward_redemption.update
  channel.charity_campaign.donate channel.charity_campaign.progress
  channel.goal.begin channel.goal.progress channel.goal.end
  channel.hype_train.begin channel.hype_train.progress channel.hype_train.end
  channel.shoutout.create channel.shoutout.receive
  stream.online stream.offline
]
```

```elixir
# config/runtime.exs

# Add to the existing bot config.
config :my_app,
  bots: [
    [
      # Example existing Bot config.
      bot: MyApp.MyBot,
      user: "myappbot",
      pass: System.fetch_env!("TWITCH_OATH_TOKEN"), # "oauth:myappbotpassword"
      channels: ["mychannel", "foo"],
      mod_channels: ["mychannel"],
      debug: false, # defaults to false
      # Adding here ===>:
      # Adding event_sub config options will start the eventsub socket.
      event_sub: [
        user_id: "123456",
        handler: MyApp.MyBot,
        client_id: System.get_env("TWITCH_CLIENT_ID"),
        access_token: System.get_env("TWITCH_ACCESS_TOKEN")
      ]
    ]
  ]
```

### Bot module

Create a bot module to deal with chat messages or events:

```elixir
defmodule MyBot do
  use TMI

  alias TMI.Events.Follow
  alias TMI.Events.Message

  @impl true
  def handle_event(%Message{message: "!" <> cmd} = event) do
    dispatch(cmd, event)
  end

  def handle_event(%Follow{} = event) do
    say(event.broadcaster_user_login, "Thanks for the follow, @#{event.user_name}")
  end

  ## Helpers

  defp dispatch("roll", %{channel: channel, display_name: user}),
    do: say(channel, "@#{user} rolled a #{Enum.random(1..6)}!")

  defp dispatch(_command, _msg),
    do: :noop
end
```

#### Available handler callbacks:

```elixir
## Receives `Event` structs from both TMI/IRC and EventSub.
handle_event(event)

## IRC-related callbacks
handle_connected(server, port)
handle_disconnected()
handle_join(channel)
handle_join(channel, user)
handle_kick(channel, kicker)
handle_kick(channel, user, kicker)
handle_logged_in()
handle_login_failed(reason)
handle_part(channel)
handle_part(channel, user)
handle_unrecognized(msg)
handle_unrecognized(msg, tags)
```

### Starting

Examples of adding it to your application's supervision tree below.

##### Single bot example:

```elixir
# lib/my_app/application.ex in `start/2` function:
defmodule MyApp.Application do
  # ...
  @impl true
  def start(_type, _args) do
    [bot_config] = Application.fetch_env!(:my_app, :bots)

    children = [
      # ... existing stuff ...
      # Add the bot.
      {TMI.Supervisor, bot_config}
    ]

    # ...
  end
  # ...
end
```

##### Multiple bots example:

```elixir
# lib/my_app/application.ex in `start/2` function:
defmodule MyApp.Application do
  # ...
  @impl true
  def start(_type, _args) do
    bots = Application.fetch_env!(:my_app, :bots)
    bot_children = for bot_config <- bots, do: {TMI.Supervisor, bot_config}

    children = [
      # If you have existing children, e.g.:
      Existing.Worker,
      {Another.Existing.Supervisor, []}
      # Add the bot children.
      | bot_children
    ]

    # ...
  end
  # ...
end
```

### To get your bot verified:

Visit https://dev.twitch.tv/limit-increase/ and have a good reason prepared.

## Copyright and License

Copyright 2020 Ryan Winchester

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
