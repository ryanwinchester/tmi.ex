defmodule TMI.MessageServer do
  @moduledoc """
  A GenServer for Sending messages at a specified rate to a single channel.

  ## Options

   - `:rate` (integer) - The rate at which to send the messages. (one message
      per `rate`). Optional. Defaults to `1500` ms.

  ### Twitch command and message rate limits:

  If command and message rate limits are exceeded, an application cannot send channel
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
  use GenServer, restart: :transient

  require Logger

  alias TMI.Client

  @default_rate_ms 1500

  @doc """
  Start the message server. Usually because of a `JOIN`.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    channel = Keyword.fetch!(opts, :channel)
    GenServer.start_link(__MODULE__, {channel, opts}, name: channel)
  end

  @doc """
  Generate the module name from bot and channel.
  """
  @spec module_name(module(), String.t()) :: module()
  def module_name(bot, channel) do
    Module.concat([bot, String.capitalize(channel), "MessageServer"])
  end

  @doc """
  Stop the message server. Usually because of a `PART`.
  """
  @spec stop(term()) :: :ok
  def stop(name) do
    GenServer.stop(name)
  end

  @doc """
  Add a command to the outbound message queue.
  """
  @spec add_command(String.t()) :: :ok
  def add_command(command) do
    GenServer.cast(__MODULE__, {:add, {:cmd, command}})
  end

  @doc """
  Add a message to the outbound message queue.
  """
  @spec add_message(String.t()) :: :ok
  def add_message(message) do
    GenServer.cast(__MODULE__, {:add, {:msg, message}})
  end

  ## Callbacks

  @impl true
  def init({channel, opts}) do
    state = %{
      conn: Keyword.fetch!(opts, :conn),
      rate: Keyword.get(opts, :rate, @default_rate_ms),
      channel: channel,
      queue: :queue.new(),
      timer_ref: nil
    }

    Logger.info("[MessageServer] [#{state.channel}] STARTING @ #{state.rate}ms...")

    {:ok, state}
  end

  @impl true
  # If we are paused, we will add it to the queue and start scheduling messages.
  def handle_cast({:add, message}, %{timer_ref: nil} = state) do
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

  defp send_and_schedule_next(state) do
    case :queue.out(state.queue) do
      {:empty, _} ->
        Logger.debug("[MessageServer] [#{state.channel}] no more messages to send: PAUSED")
        {:noreply, %{state | timer_ref: nil}}

      {{:value, {type, message}}, rest} ->
        send_message(type, message, state.conn, state.channel)
        Logger.debug("[MessageServer] [#{state.channel}] SENT #{type}: #{message}")
        timer_ref = Process.send_after(self(), :send, state.rate)
        {:noreply, %{state | queue: rest, timer_ref: timer_ref}}
    end
  end

  # Twitch mentions rate limites apply to channel commands, but I'm not sure
  # which commands those are specifically. I made it possible to send commands
  # from this module, but more work is needed to know what this applies to
  # before we actually implement the `:cmd` functionality properly.
  defp send_message(:cmd, command, conn, _channel), do: Client.command(conn, command)
  defp send_message(:msg, message, conn, channel), do: Client.message(conn, channel, message)
end
