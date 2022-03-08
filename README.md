# tmi.ex

Connect to Twitch chat with Elixir.

The name is inspired by [tmi.js](https://github.com/tmijs/tmi.js).

## Installation

The package can be installed by adding `tmi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tmi, "~> 0.4.0"},
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

  @impl TMI.Handler
  def handle_message("!" <> command, sender, chat) do
    case command do
      "dice" ->
        say(chat, Enum.random(~w(⚀ ⚁ ⚂ ⚃ ⚄ ⚅)))

      "echo " <> rest ->
        say(chat, rest)

      "dance" ->
        me(chat, "dances for #{sender}")

      _ ->
        say(chat, "unrecognized command")
    end
  end

  def handle_message(message, sender, chat) do
    Logger.debug("Message in #{chat} from #{sender}: #{message}")
  end
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
    handle_message(message, sender, chat)
    handle_mention(message, sender, chat)
    handle_action(message, sender, chat)
    handle_unrecognized(msg)

### Starting

First we need to go over the config options.

#### Config options

 * `:bot` - The module that `use`s `TMI` and implements the `TMI.Handler` behaviour.
 * `:user` - Twitch username of your bot user (lowercase).
 * `:pass` - OAuth token to use as a password, prefixed with `oauth:`.
 * `:channels` - The list of channels to join (lowercase).
 * `:capabilities` - An optional list of `:tmi` capabilities, defined [here](https://dev.twitch.tv/docs/irc/guide#twitch-irc-capabilities).
   Can be any of: `"membership"`, `"tags"`, and `"commands"`. Defaults to `['membership']` (lowercase).

##### Capabilities

 * `membership` - Shows `JOIN`s and `PART`s, so you can see when a user joins or leaves chat. [docs](https://dev.twitch.tv/docs/irc/membership)
 * `tags` - Will give you a bunch of additional channel and user state data (badges, etc). [docs](https://dev.twitch.tv/docs/irc/tags)
 * `commands` - Gives you some Twitch-specific commands. If your bot plans to read commands, it must
   also use the `tags` capability because most commands are less useful or even meaningless without tags. [docs](https://dev.twitch.tv/docs/irc/commands)

#### Example config

```elixir
config :my_app,
  bots: [
    [
      bot: MyApp.Bot,
      user: "myappbot",
      pass: "oauth:myappbotpassword",
      channels: ["mychannel"]
    ]
  ]
```

### Add to your supervision tree

```elixir
bots = Application.fetch_env!(:my_app, :bots)
children = for bot_config <- bots, do: {TMU.Supervisor, bot_config}

Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
```
