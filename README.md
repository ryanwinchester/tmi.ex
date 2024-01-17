# TMI (Twitch Messaging Interface) for Elixir

[![Hex.pm](https://img.shields.io/hexpm/v/tmi)](https://hex.pm/packages/tmi)
 [![Hex.pm](https://img.shields.io/hexpm/dt/tmi)](https://hex.pm/packages/tmi)
 [![Hex.pm](https://img.shields.io/hexpm/l/tmi)](https://github.com/ryanwinchester/tmi.ex/blob/main/LICENSE)

Connect to Twitch chat with Elixir.

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

You can use your own Twitch username, but it is recommended to make a new twitch account just for your bot.
You'll also need an OAuth token for the password.

The simplest method to get an OAuth token (while logged in to the account your bot will use), use the [Twitch Chat OAuth Password Generator](https://twitchapps.com/tmi/).

Create a bot module to deal with chat messages or events:

```elixir
defmodule MyBot do
  use TMI

  alias TMI.Events.Message

  @impl true
  def handle_event(%Message{message: "!" <> cmd} = event) do
    cmd(cmd, event)
  end

  # ... TODO: match on other you're interested in ...

  ## Helpers

  defp cmd("roll", %Message{channel: channel, display_name: user}),
    do: say(channel, "@#{user} rolled a #{Enum.random(1..6)}!")

  defp cmd("echo " <> rest, %Message{channel: channel}),
    do: say(channel, rest)

  defp cmd("dance", %Message{channel: channel, display_name: user}),
    do: me(channel, "dances for @#{user}")

  defp cmd(_command, msg),
    do: say(msg.channel, "unrecognized command")
end
```

#### Available handler callbacks:

    handle_connected(server, port)
    handle_logged_in()
    handle_login_failed(reason)
    handle_disconnected()
    handle_join(chat)
    handle_join(chat, user)
    handle_part(chat)
    handle_part(chat, user)
    handle_kick(chat, kicker)
    handle_kick(chat, user, kicker)
    handle_whisper(message, sender)
    handle_whisper(message, sender, tags)
    handle_message(message, sender, chat)
    handle_message(message, sender, chat, tags)
    handle_mention(message, sender, chat)
    handle_action(message, sender, chat)
    handle_unrecognized(msg)
    handle_unrecognized(msg, tags)

### Starting

First we need to go over the config options.

#### Config options

 * `:bot` - The module that `use`s `TMI` and implements the `TMI.Handler` behaviour.
 * `:user` - Twitch username of your bot user (lowercase).
 * `:pass` - OAuth token to use as a password, prefixed with `oauth:`.
 * `:channels` - The list of channels to join (lowercase).
 * `:mod_channels` - The list of channels where your bot is a moderator
   (this effects the message and command rate limits).

#### Example config

```elixir
# config/runtime.exs

config :my_app,
  bots: [
    [
      bot: MyApp.Bot,
      user: "myappbot",
      pass: System.fetch_env!("TWITCH_OATH_TOKEN"), # "oauth:myappbotpassword"
      channels: ["mychannel", "foo"],
      mod_channels: ["mychannel"],
      debug: false # defaults to false
    ]
  ]
```

### Add to your supervision tree

##### Single bot example:

```elixir
# lib/my_app/application.ex

[bot_config] = Application.fetch_env!(:my_app, :bots)

children = [
  # If you have existing children, e.g.:
  Existing.Worker,
  {Another.Existing.Supervisor, []},
  # Add the bot.
  {TMI.Supervisor, bot_config}
]

Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
```

##### Multiple bots example:

```elixir
bots = Application.fetch_env!(:my_app, :bots)
bot_children = for bot_config <- bots, do: {TMI.Supervisor, bot_config}

children = [
  # If you have existing children, e.g.:
  Existing.Worker,
  {Another.Existing.Supervisor, []}
  # Add the bot children.
  | bot_children
]

Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
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

## For the memes

![roxcar76](https://user-images.githubusercontent.com/2897340/163022131-e86af85b-6b2f-4ee8-b44b-486f267ac7bd.png)
