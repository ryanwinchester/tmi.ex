defmodule TMI.DynamicMessageServer do
  @moduledoc """
  A GenServer for Sending messages at a specified rate.

  ## Options

   - `:rate` (integer) - The rate at which to send the messages. (one message
      per `rate`). Optional. Defaults to `1500` ms.

  ### Twitch command and message rate limits:

  If command and message rate limits are exceeded, an application cannot send chat
  messages or commands for 30 minutes.

  | Limit                         | Applies to
  |-------------------------------|---------------------------------------------
  | 20 per 30 seconds             | Users sending commands or messages to
  |                               | channels in which they are not the broadcaster
  |                               | and do not have Moderator status.
  |                               | .
  | 100 per 30 seconds 	          | Users sending commands or messages to channels
  |                               | in which they are the broadcaster or have
  |                               | Moderator status.
  |                               | .
  | 7500 per 30 seconds           | Verified bots. The channel limits above also
  | site-wide                     | apply. In other words, one of the two limits
  |                               | above will also be applied depending on
  |                               | whether the verified bot is the broadcaster
  |                               | or has Moderator status.

  https://dev.twitch.tv/docs/irc/guide#rate-limits

  """
  use GenServer

  require Logger

  @default_rate_ms 1500

  @doc """
  Start the message server. Usually because of a `JOIN`.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    chat = Keyword.fetch!(opts, :chat)
    GenServer.start_link(__MODULE__, {chat, opts}, name: chat)
  end

  @doc """
  Stop the message server. Usually because of a `PART`.
  """
  @spec stop(term()) :: :ok
  def stop(name) do
    GenServer.stop(name)
  end

  @doc """
  Add a message to the outbound message queue.
  """
  @spec add_message(String.t()) :: :ok
  def add_message(message) do
    GenServer.cast(__MODULE__, {:add, message})
  end

  ## Callbacks

  @impl true
  def init({chat, opts}) do
    state = %{
      chat: chat,
      rate: Keyword.get(opts, :rate, @default_rate_ms),
      queue: :queue.new(),
      paused?: true
    }

    Logger.info("[DynamicMessageServer] STARTING for #{state.chat} @ #{state.rate}ms...")

    {:ok, state}
  end

  @impl true
  # If we are paused, we will add it to the queue and start scheduling messages.
  def handle_cast({:add, message}, %{paused?: true} = state) do
    send_and_schedule_next(%{state | queue: :queue.in(message, state.queue)})
  end

  # It is not paused, so that means we are still scheduling messages, so we will
  # just add the message to queue.
  def handle_cast({:add, message}, state) do
    {:noreply, %{state | queue: :queue.in(message, state.queue)}}
  end

  @impl true
  def handle_info(:send, state) do
    send_and_schedule_next(state)
  end

  ## Internal API

  # Pops a message off the queue and sends it.
  defp send_and_schedule_next(state) do
    case :queue.out(state.queue) do
      {:empty, _} ->
        Logger.debug("[DynamicMessageServer] no more messages to send: PAUSED")
        {:noreply, %{state | paused?: true}}

      {{:value, message}, rest} ->
        TMI.message(state.chat, message)
        Logger.debug("[DynamicMessageServer] SENT #{state.chat}: #{message}")
        Process.send_after(self(), :send, state.rate)
        {:noreply, %{state | queue: rest, paused?: false}}
    end
  end
end
