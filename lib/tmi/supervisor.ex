defmodule TMI.Supervisor do
  @moduledoc """
  TMI is a library for connecting to Twitch chat with Elixir.
  """
  use Supervisor

  @doc """
  Start the TMI supervisor.
  """
  @spec start_link(keyword()) :: Supervisor.on_start()
  def start_link(opts) do
    {bot, opts} = Keyword.pop!(opts, :bot)
    default_name = Module.concat([bot, "BotSupervisor"])
    {name, opts} = Keyword.pop(opts, :name, default_name)

    Supervisor.start_link(__MODULE__, {bot, opts}, name: name)
  end

  @impl true
  def init({bot, opts}) do
    {is_verified, opts} = Keyword.pop(opts, :is_verified, false)
    {mod_channels, opts} = Keyword.pop(opts, :mod_channels, [])

    {:ok, client} = TMI.Client.start_link(Keyword.take(opts, [:debug]))
    conn = build_conn(client, opts)

    dynamic_supervisor = TMI.MessageServer.supervisor_name(bot)

    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: dynamic_supervisor},
      # {TMI.ChannelServer, {bot, conn, is_verified, mod_channels}},
      # {TMI.ConnectionServer, {bot, conn}},
      # {TMI.WhisperServer, {bot, conn}},
      {bot, conn}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp build_conn(client, config) do
    user = Keyword.fetch!(config, :user)
    pass = Keyword.fetch!(config, :pass)
    channels = Keyword.get(config, :channels, [])

    caps =
      config
      |> Keyword.get(:capabilities, ['membership', 'tags', 'commands'])
      |> to_charlist()

    TMI.Conn.new(client, user, pass, channels, caps)
  end
end
