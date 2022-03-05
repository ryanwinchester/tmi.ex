defmodule TMI.ChatServer do
  @moduledoc """
  A GenServer for Chats.

  ## Options

   - `:rate` (integer) - The rate at which to join chats. (one join per `rate`).
      Optional. Defaults to `500` ms.

  ### Twitch authentication and join rate limits:

  If command and message rate limits are exceeded, an application cannot send chat
  messages or commands for 30 minutes.

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

  @default_rate_ms 500

  @doc """
  Start the chat server.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Add a chat to the JOIN queue.
  """
  @spec join(String.t()) :: :ok
  def join(chat) do
    GenServer.cast(__MODULE__, {:join, chat})
  end

  @doc """
  Add a chat to the PART queue.
  """
  @spec part(String.t()) :: :ok
  def part(chat) do
    GenServer.cast(__MODULE__, {:part, chat})
  end

  ## Callbacks

  @impl true
  def init(opts) do
    state = %{
      rate: Keyword.get(opts, :rate, @default_rate_ms),
      queue: :queue.new(),
      paused?: true
    }

    Logger.info("[ChatServer] STARTING with rate of #{state.rate}ms...")

    {:ok, state}
  end

  @impl true
  # If we are paused, we will add it to the queue and start scheduling joins.
  def handle_cast({:join, chat}, %{paused?: true} = state) do
    join_and_schedule_next(%{state | queue: :queue.in(chat, state.queue)})
  end

  # It is not paused, so that means we are still scheduling JOINS, so we will
  # just add the chat to the queue.
  def handle_cast({:join, chat}, state) do
    {:noreply, %{state | queue: :queue.in(chat, state.queue)}}
  end

  # Performs a PART on the chat. Deletes it from the queue in case we have not
  # actually JOINED it yet.
  def handle_cast({:part, chat}, state) do
    # TODO: TMI.part(chat)
    Logger.info("[ChatServer] PARTED #{chat}")
    {:noreply, %{state | queue: :queue.delete(chat, state.queue)}}
  end

  @impl true
  def handle_info(:send, state) do
    join_and_schedule_next(state)
  end

  ## Internal API

  # Pops a chat off the queue and JOINS it.
  defp join_and_schedule_next(state) do
    case :queue.out(state.queue) do
      {:empty, _} ->
        Logger.debug("[ChatServer] no more chats to join: PAUSED")
        {:noreply, %{state | paused?: true}}

      {{:value, chat}, rest} ->
        # TODO: TMI.join(chat)
        Logger.info("[ChatServer] JOINED #{chat}")
        Process.send_after(self(), :join, state.rate)
        {:noreply, %{state | queue: rest, paused?: false}}
    end
  end
end
