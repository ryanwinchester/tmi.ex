defmodule TMI do
  @moduledoc """
  TMI is a library for connecting to Twitch chat with Elixir.

  See the [README](https://hexdocs.pm/tmi/readme.html) for more details.
  """
  use GenServer

  alias TMI.Conn

  ## Public API

  def supervisor_start_link(config) do
    TMI.Supervisor.start_link(config)
  end

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @doc false
  def build_conn(config) do
    user = Keyword.fetch!(config, :user)
    pass = Keyword.fetch!(config, :pass)
    chats = Keyword.get(config, :chats, [])
    caps = Keyword.get(config, :capabilities, [])

    {:ok, client} = ExIRC.start_link!()

    TMI.Conn.new(client, user, pass, chats, caps)
  end

  def send_msg(channel, msg) do
    GenServer.cast(__MODULE__, {:send_msg, channel, msg})
  end

  ## Callbacks

  @impl true
  def init(%Conn{} = conn) do
    {:ok, conn}
  end

  def init(config) do
    config
    |> build_conn()
    |> init()
  end

  @impl true
  def handle_cast({:send_msg, channel, msg}, conn) do
    :ok = ExIRC.Client.msg(conn.client, :privmsg, "#" <> channel, msg)
    {:noreply, conn}
  end
end
