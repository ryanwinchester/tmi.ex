defmodule TMI.Supervisor do
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
    conn = TMI.build_conn(config)
    handler = Keyword.get(config, :handler, TMI.DefaultHandler)

    children = [
      {TMI, conn},
      {TMI.Handlers.ConnectionHandler, conn},
      {TMI.Handlers.LoginHandler, conn},
      {TMI.Handlers.MessageHandler, {conn, handler}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
