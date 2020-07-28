# tmi.ex

Connect to Twitch chat with Elixir.

Inspired by [tmi.js](https://github.com/tmijs/tmi.js).

## Installation

The package can be installed by adding `tmi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tmi, "~> 0.1.0"},
  ]
end
```

Documentation can be found at [https://hexdocs.pm/tmi/readme.html](https://hexdocs.pm/tmi/readme.html).

## Usage

You can use your own Twitch username, but it is recommended to make a new twitch account just for your bot.
You'll also need an OAuth token for the password.

The simplest method to get an OAuth token (while logged in to the account your bot will be) use the [Twitch Chat OAuth Password Generator](https://twitchapps.com/tmi/).

To connect, start the supervisor with:

```elixir
user = "mybotusername"
pass = "oauth:mybotoauthtoken"
chats = ["mychat", "myfriendschat"]

{:ok, _pid} = TMI.Supervisor.start_link(user, pass, chats)
```

#### TODO: All the typical bot stuff.
