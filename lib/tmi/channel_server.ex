defmodule TMI.ChannelServer do
  @moduledoc """
  A GenServer for Channels.

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

  @default_rate_ms 500

  @doc """
  Start the channel server.
  """
  @spec start_link({module(), Conn.t()}) :: GenServer.on_start()
  def start_link({bot, conn}) do
    name = Module.concat([bot, "ChannelServer"])
    GenServer.start_link(__MODULE__, {bot, conn}, name: name)
  end

  @doc """
  Update the config in the state.
  """
  @spec set_config(keyword()) :: :ok
  def set_config(opts) when is_list(opts) do
    GenServer.cast(__MODULE__, {:set_config, opts})
  end

  @doc """
  Add a channel to the JOIN queue.
  """
  @spec join(String.t()) :: :ok
  def join(channel) do
    GenServer.cast(__MODULE__, {:join, channel})
  end

  @doc """
  Add a channel to the PART queue.
  """
  @spec part(String.t()) :: :ok
  def part(channel) do
    GenServer.cast(__MODULE__, {:part, channel})
  end

  ## Callbacks

  @impl true
  def init({bot, conn}) do
    state = %{
      bot: bot,
      conn: conn,
      rate: @default_rate_ms,
      queue: :queue.new(),
      timer_ref: nil
    }

    Logger.info("[#{bot}.ChannelServer] STARTING with rate of #{state.rate}ms...")

    {:ok, state}
  end

  @impl true
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
    apply(message_server(state.bot, channel), :stop, [])
    {:noreply, %{state | queue: :queue.delete(channel, state.queue)}}
  end

  @impl true
  def handle_info(:send, state) do
    join_and_schedule_next(state)
  end

  ## Internal API

  defp join_and_schedule_next(state) do
    case :queue.out(state.queue) do
      {:empty, _} ->
        Logger.debug("[#{state.bot}.ChannelServer] no more channels to join: PAUSED")
        {:noreply, %{state | timer_ref: nil}}

      {{:value, channel}, rest} ->
        Client.join(state.conn, channel)

        DynamicSupervisor.start_child(
          message_server_supervisor(state.bot),
          message_server(state.bot, channel)
        )

        Logger.info("[#{state.bot}.ChannelServer] JOINED #{channel}")
        timer_ref = Process.send_after(self(), :join, state.rate)
        {:noreply, %{state | queue: rest, timer_ref: timer_ref}}
    end
  end

  defp message_server_supervisor(bot) do
    Module.concat([bot, "MessageServerSupervisor"])
  end

  defp message_server(bot, channel) do
    Module.concat([bot, String.capitalize(channel), "MessageServer"])
  end
end
