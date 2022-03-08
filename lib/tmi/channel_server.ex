defmodule TMI.ChannelServer do
  @moduledoc """
  A GenServer for Channels that self-rate-limits joins.

  ## Options

   - `:rate` (integer) - The rate at which to join channels. (one join per `rate`).
      Optional. Defaults to `500` ms.

  ### Twitch authentication and join rate limits:

  | Limit                         | Applies to
  |-------------------------------|---------------------------------------------
  | 20 join attempts per 10       | Regular Twitch account
  | seconds per user              | .
  |                               | .
  | 2000 join attempts per 10     | Verified bot
  | seconds per user              | .

  https://dev.twitch.tv/docs/irc/guide#rate-limits

  """
  use GenServer

  require Logger

  alias TMI.Client
  alias TMI.Conn
  alias TMI.MessageServer

  @default_join_rate_ms 500

  @default_message_rate_ms 1500

  # ----------------------------------------------------------------------------
  # Public API
  # ----------------------------------------------------------------------------

  @doc """
  Start the channel server.
  """
  @spec start_link({module(), Conn.t()}) :: GenServer.on_start()
  def start_link({bot, conn}) do
    GenServer.start_link(__MODULE__, {bot, conn}, name: module_name(bot))
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
  def init({bot, conn}) do
    state = %{
      bot: bot,
      conn: conn,
      rate: @default_join_rate_ms,
      queue: :queue.new(),
      timer_ref: nil
    }

    Logger.info("[#{bot}.ChannelServer] STARTING with rate of #{state.rate}ms...")

    {:ok, state}
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
    Client.part(state.conn, channel)
    Logger.info("[#{state.bot}.ChannelServer] PARTED #{channel}")
    stop_channel_message_server(state.bot, channel)
    {:noreply, %{state | queue: :queue.delete(channel, state.queue)}}
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
        Client.join(state.conn, channel)
        start_channel_message_server(state.bot, state.conn, channel)
        Logger.info("[#{state.bot}.ChannelServer] JOINED #{channel}")
        timer_ref = Process.send_after(self(), :join, state.rate)
        {:noreply, %{state | queue: rest, timer_ref: timer_ref}}
    end
  end

  # TODO: See if we can adjust channel message rate based on if we are the
  # broadcaster or mod in a specific channel. Probably means Twitch API calls
  # or using the special Twitch IRC `capabilities`.
  defp start_channel_message_server(bot, conn, channel) do
    {:ok, _} =
      DynamicSupervisor.start_child(
        message_server_supervisor(bot),
        {MessageServer, {bot, channel, conn: conn, rate: @default_message_rate_ms}}
      )
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
