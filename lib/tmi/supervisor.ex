defmodule TMI.Supervisor do
  @moduledoc """
  TMI is a library for connecting to Twitch chat with Elixir.

  ## Example bot:

      defmodule FooBot do
        use TMI.Bot

        @impl TMI.Bot
        def hear("!roll", _channel, sender) do
          roll = Enum.random(1..6)
          say(channel, "\#{sender} rolls \#{roll}")
        end

        def hear(_msg, _channel, _sender) do
          :noop
        end
      end

  ## Example, add to supervision tree:

        foobot_config = [
          user: "fooman",
          pass: "oath:mytwitchtoken",
          channels: ["fooman"],
          capabilities: ['membership']
        ]

        children = [
          {TMI.Supervisor,
            name: FooBotSupervisor,
            bot: FooBot,
            config: foobot_config}
        ]

        Supervisor.init(children, strategy: :one_for_one)

  """
  use Supervisor

  @doc """
  Start the TMI supervisor.
  """
  @spec start_link(keyword()) :: Supervisor.on_start()
  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name, __MODULE__)
    Supervisor.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(opts) do
    {:ok, client} = ExIRC.Client.start_link()

    bot = Keyword.fetch!(opts, :bot)
    conn = build_conn(client, opts)

    # Name the other processes as part of the bot to not conflict with other
    # bots if you start more than one.
    dynamic_supervisor = Module.concat([bot, "DynamicSupervisor"])

    children = [
      {DynamicSupervisor, name: dynamic_supervisor},
      {TMI.ChannelServer, {bot, conn}},
      {TMI.ConnectionHandler, {bot, conn}},
      {bot, conn}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp build_conn(client, config) do
    user = Keyword.fetch!(config, :user)
    pass = Keyword.fetch!(config, :pass)
    channels = Keyword.get(config, :channels, [])
    caps = Keyword.get(config, :capabilities, ['membership'])

    TMI.Conn.new(client, user, pass, channels, caps)
  end
end
