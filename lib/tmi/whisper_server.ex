defmodule TMI.WhisperServer do
  @moduledoc """
  A GenServer for Sending whispers at a specified rate.

  ### Twitch whispers rate limits:

  If the Whisper rate limits are exceeded, an application cannot send Whispers
  for 24 hours.

      | Limit                               | Applies to
      |-------------------------------------|-----------------------
      | 3 per second, up to 100 per minute, | All Twitch accounts
      | for 40 accounts per day             | .

  https://dev.twitch.tv/docs/irc/guide#rate-limits

  """
  use GenServer, restart: :transient

  require Logger

  alias TMI.Client
  alias TMI.Conn

  @default_rate_ms 625

  # ----------------------------------------------------------------------------
  # Public API
  # ----------------------------------------------------------------------------

  @doc """
  Start the message server. Usually because of a `JOIN`.
  """
  @spec start_link({module(), Conn.t()}) :: GenServer.on_start()
  def start_link({bot, conn}) do
    GenServer.start_link(__MODULE__, {bot, conn}, name: module_name(bot))
  end

  @doc """
  Stop the message server. Usually because of a `PART`.
  """
  @spec stop(module()) :: :ok
  def stop(bot) do
    module_name(bot) |> GenServer.stop()
  end

  @doc """
  Add a whisper to the outbound message queue.
  """
  @spec add_whisper(module(), String.t(), String.t(), String.t()) :: :ok
  def add_whisper(bot, from, to, whisper) do
    module_name(bot) |> GenServer.cast({:add, {from, to, whisper}})
  end

  @doc """
  Generate the bot specific module name.
  """
  @spec module_name(module()) :: module()
  def module_name(bot) do
    Module.concat([bot, "WhisperServer"])
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
      rate: @default_rate_ms,
      queue: :queue.new(),
      timer_ref: nil
    }

    Logger.info("[#{module_name(bot)}] STARTING @ #{state.rate}ms...")

    {:ok, state}
  end

  @doc """
  Invoked to handle asynchronous `cast/2` messages.
  """
  @impl GenServer
  # If we are paused, we will add it to the queue and start scheduling messages.
  def handle_cast({:add, message}, %{timer_ref: nil} = state) do
    send_and_schedule_next(%{state | queue: :queue.in(message, state.queue)})
  end

  # It is not paused, so that means we are still scheduling messages, so we will
  # just add the message to queue.
  def handle_cast({:add, message}, state) do
    {:noreply, %{state | queue: :queue.in(message, state.queue)}}
  end

  @doc """
  Invoked to handle all other messages.

  For example calling `Process.send_after(self(), :foo, 1000)` would send `:foo`
  after one second, and we could match on that here.
  """
  @impl GenServer
  def handle_info(:send, state) do
    send_and_schedule_next(state)
  end

  # ----------------------------------------------------------------------------
  # Internal API
  # ----------------------------------------------------------------------------

  defp send_and_schedule_next(state) do
    case :queue.out(state.queue) do
      {:empty, _} ->
        Logger.debug("[WhisperServer] no more whispers to send: PAUSED")
        {:noreply, %{state | timer_ref: nil}}

      {{:value, {from, to, message}}, rest} ->
        Client.command(state.conn, ['PRIVMSG ', from, ' :/w ', to, ' ', message])
        Logger.debug("[WhisperServer] #{from} WHISPERED #{to}: #{message}")
        timer_ref = Process.send_after(self(), :send, state.rate)
        {:noreply, %{state | queue: rest, timer_ref: timer_ref}}
    end
  end
end
