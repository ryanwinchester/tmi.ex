defmodule TMI.ChannelServer do
  @moduledoc """
  A GenServer for Channels that self-rate-limits joins.

  ## Options

   - `:rate` (integer) - The rate at which to join channels. (one join per `rate`).
      Optional. Defaults to `500` ms.

  ### Twitch authentication and join rate limits:

      | Limit                         | Applies to
      |-------------------------------|-------------------------
      | 20 join attempts per 10       | Regular Twitch account
      | seconds per user              |
      |                               |
      | 2000 join attempts per 10     | Verified bot
      | seconds per user              |

  https://dev.twitch.tv/docs/irc/guide#rate-limits

  """
  use GenServer

  require Logger

  alias TMI.Client
  alias TMI.Conn
  alias TMI.MessageServer

  @default_join_rate_ms 500
  @verified_join_rate_ms 5

  @hibernate_after_ms 60_000

  # ----------------------------------------------------------------------------
  # Public API
  # ----------------------------------------------------------------------------

  @doc """
  Start the channel server.
  """
  @spec start_link({module(), Conn.t(), boolean(), [String.t()]}) :: GenServer.on_start()
  def start_link({bot, conn, is_verified, mod_channels}) do
    GenServer.start_link(__MODULE__, {bot, conn, is_verified, mod_channels},
      name: module_name(bot),
      hibernate_after: @hibernate_after_ms
    )
  end

  @doc """
  Add a channel to the JOIN queue.
  """
  @spec join(module(), String.t()) :: :ok
  def join(bot, channel) do
    GenServer.cast(module_name(bot), {:join, channel})
  end

  @doc """
  PART from a channel.
  """
  @spec part(module(), String.t()) :: :ok
  def part(bot, channel) do
    GenServer.cast(module_name(bot), {:part, channel})
  end

  @doc """
  List the channels that we have joined.
  """
  @spec list_channels(module()) :: [String.t()]
  def list_channels(bot) do
    GenServer.call(module_name(bot), :list_channels)
  end

  @doc """
  Update the moderator status of a mod for a channel.
  """
  @spec update_mod_status(module(), String.t(), boolean()) :: :ok
  def update_mod_status(bot, channel, mod_status) do
    GenServer.cast(module_name(bot), {:update_mod_status, channel, mod_status})
  end

  @doc """
  Get the bot-specific ChannelServer module name.
  """
  @spec module_name(module()) :: module()
  def module_name(bot) do
    Module.concat([bot, "ChannelServer"])
  end

  # ----------------------------------------------------------------------------
  # GenServer callbacks
  # ----------------------------------------------------------------------------

  @doc """
  Invoked when the server is started. `start_link/3` will block until it
  returns.
  """
  @impl GenServer
  def init({bot, conn, is_verified, mod_channels}) do
    state = %{
      bot: bot,
      channels: MapSet.new(),
      mod_channels: MapSet.new(mod_channels),
      conn: conn,
      rate: if(is_verified, do: @verified_join_rate_ms, else: @default_join_rate_ms),
      queue: :queue.new(),
      timer_ref: nil
    }

    Logger.info("[#{bot}.ChannelServer] STARTING with rate of #{state.rate}ms...")

    {:ok, state}
  end

  @doc """
  Invoked to handle synchronous `call/3` messages. `call/3` will block until a
  reply is received (unless the call times out or nodes are disconnected).
  """
  @impl GenServer
  def handle_call(:list_channels, _from, state) do
    {:reply, state.channels, state}
  end

  @doc """
  Invoked to handle asynchronous `cast/2` messages.
  """
  @impl GenServer
  def handle_cast({:set_config, opts}, state) do
    config = Enum.into(opts, %{}) |> Map.take([:rate])
    Logger.info("[#{state.bot}.ChannelServer] Updating config with: #{inspect(config)}")
    {:noreply, Map.merge(state, config)}
  end

  # If we are paused, we will add it to the queue and start scheduling joins.
  def handle_cast({:join, channel}, %{timer_ref: nil} = state) do
    join_and_schedule_next(%{state | queue: :queue.in(channel, state.queue)})
  end

  # It is not paused, so that means we are still scheduling JOINS, so we will
  # just add the channel to the queue.
  def handle_cast({:join, channel}, state) do
    {:noreply, %{state | queue: :queue.in(channel, state.queue)}}
  end

  # Performs a PART on the channel. Deletes it from the queue in case we have not
  # actually JOINED it yet.
  def handle_cast({:part, channel}, state) do
    %{bot: bot, channels: channels, conn: conn, queue: queue} = state
    Client.part(conn, channel)
    Logger.info("[#{bot}.ChannelServer] PARTED #{channel}")
    stop_channel_message_server(bot, channel)
    channels = MapSet.delete(channels, channel)
    {:noreply, %{state | queue: :queue.delete(channel, queue), channels: channels}}
  end

  def handle_cast({:update_mod_status, channel, mod_status}, state) do
    %{bot: bot, channels: channels} = state

    case {MapSet.member?(channels, channel), mod_status} do
      {true, false} ->
        update_channel_message_server_mod_status(bot, channel, mod_status)
        {:noreply, %{state | channels: MapSet.delete(channels, channel)}}

      {false, true} ->
        update_channel_message_server_mod_status(bot, channel, mod_status)
        {:noreply, %{state | channels: MapSet.put(channels, channel)}}

      _ ->
        {:noreply, state}
    end
  end

  @doc """
  Invoked to handle all other messages.

  For example calling `Process.send_after(self(), :foo, 1000)` would send `:foo`
  after one second, and we could match on that here.
  """
  @impl GenServer
  def handle_info(:join, state) do
    join_and_schedule_next(state)
  end

  # ----------------------------------------------------------------------------
  # Internal API
  # ----------------------------------------------------------------------------

  defp join_and_schedule_next(state) do
    case :queue.out(state.queue) do
      {:empty, _} ->
        Logger.info("[#{state.bot}.ChannelServer] no more channels to join: PAUSED")
        {:noreply, %{state | timer_ref: nil}}

      {{:value, channel}, rest} ->
        %{bot: bot, channels: channels, conn: conn, rate: rate} = state
        Client.join(conn, channel)
        is_mod = MapSet.member?(state.mod_channels, channel)
        start_channel_message_server(bot, conn, channel, is_mod)
        Logger.info("[#{bot}.ChannelServer] JOINED #{channel}")
        timer_ref = Process.send_after(self(), :join, rate)
        channels = MapSet.put(channels, channel)
        {:noreply, %{state | queue: rest, timer_ref: timer_ref, channels: channels}}
    end
  end

  defp start_channel_message_server(bot, conn, channel, is_mod) do
    {:ok, _} =
      DynamicSupervisor.start_child(
        message_server_supervisor(bot),
        {MessageServer, {bot, channel, is_mod, conn}}
      )
  end

  defp update_channel_message_server_mod_status(bot, channel, mod_status) do
    message_server(bot, channel) |> MessageServer.update_mod_status(mod_status)
  end

  defp stop_channel_message_server(bot, channel) do
    message_server(bot, channel) |> MessageServer.stop()
  end

  defp message_server_supervisor(bot) do
    MessageServer.supervisor_name(bot)
  end

  defp message_server(bot, channel) do
    MessageServer.module_name(bot, channel)
  end
end
