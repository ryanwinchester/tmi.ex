defmodule TMI.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config, name: __MODULE__)
  end

  @impl true
  def init(config) do
    user = Keyword.fetch!(config, :user)
    pass = Keyword.fetch!(config, :pass)
    channels = Keyword.get(config, :channels, [])

    {:ok, client} = ExIRC.start_link!()

    conn = TMI.Conn.new(client, user, pass, channels)

    children = [
      {TMI.Handlers.ConnectionHandler, conn},
      {TMI.Handlers.LoginHandler, conn}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
