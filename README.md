# tmi.ex

Connect to Twitch chat with Elixir.

Inspired by [tmi.js](https://github.com/tmijs/tmi.js).

## Installation

The package can be installed by adding `tmi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tmi, "~> 0.2.0"},
  ]
end
```

Documentation can be found at [https://hexdocs.pm/tmi/readme.html](https://hexdocs.pm/tmi/readme.html).

## Usage

You can use your own Twitch username, but it is recommended to make a new twitch account just for your bot.
You'll also need an OAuth token for the password.

The simplest method to get an OAuth token (while logged in to the account your bot will use), use the [Twitch Chat OAuth Password Generator](https://twitchapps.com/tmi/).

First we need to go over the config options.

### Config options

 * `:user` - Twitch username of your bot user. (lowercase)
 * `:pass` - OAuth token to use as a password, prefixed with `oauth:`.
 * `:chats` - The list of chats to join. (lowercase)
 * `:capabilities` - An optional list of `:tmi` capabilities, defined [here](https://dev.twitch.tv/docs/irc/guide#twitch-irc-capabilities). Can be any of: `"membership"`, `"tags"`, and `"commands"`. (lowercase)

#### Capabilities

 * `membership` - Shows `JOIN`s and `PART`s, so you can see when a user joins or leaves chat. [docs](https://dev.twitch.tv/docs/irc/membership)
 * `tags` - Will give you a bunch of additional channel and user state data (badges, etc). [docs](https://dev.twitch.tv/docs/irc/tags)
 * `commands` - Gives you some Twitch-specific commands. If your bot plans to read commands, it must
   also use the `tags` capability because most commands are less useful or even meaningless without tags. [docs](https://dev.twitch.tv/docs/irc/commands)


Next, we can connect. Start `TMI` with:

```elixir
config = [
  user: "mybotusername",
  pass: "oauth:mybotoauthtoken",
  chats: ["mychat"]
]

TMI.supervisor_start_link(config)
```

To send a message

```elixir
TMI.send_msg("mychat", "Hello World")
```

#### TODO: All the typical bot stuff.

