defmodule TMI do
  @moduledoc """
  TMI is a library for connecting to Twitch chat with Elixir.

  See the [README](https://hexdocs.pm/tmi/readme.html) for more details.
  """
  use Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config, name: __MODULE__)
  end

  @impl true
  def init(config) do
    user = Keyword.fetch!(config, :user)
    pass = Keyword.fetch!(config, :pass)
    chats = Keyword.get(config, :chats, [])
    caps = Keyword.get(config, :capabilities, [])

    {:ok, client} = ExIRC.start_link!()

    conn = TMI.Conn.new(client, user, pass, chats, caps)

    children = [
      {TMI.Handlers.ConnectionHandler, conn},
      {TMI.Handlers.LoginHandler, conn}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
