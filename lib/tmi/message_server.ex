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
      |                               |
      | 100 per 30 seconds            | Users sending commands or messages to channels
      |                               | in which they are the broadcaster or have
      |                               | Moderator status.
      |                               |
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
  alias TMI.Conn

  # The default is the general case for when the bot is not the broadcaster
  # or a moderator in a channel. 20 messages per 30 seconds works out to
  # exactly 1500ms delay. [1000 / (20 / 30)]
  @default_rate_ms 1500

  # The mod rate is 100 messages per 30 seconds works out to
  # Change the message rate when the moderator status changes.
  # exactly 300ms delay. [1000 / (100 / 30)]
  @mod_rate_ms 300

  @hibernate_after_ms 15 * 60 * 1000

  # ----------------------------------------------------------------------------
  # Public API
  # ----------------------------------------------------------------------------

  @doc """
  Start the message server. Usually because of a `JOIN`.
  """
  @spec start_link({module(), String.t(), boolean(), Conn.t()}) :: GenServer.on_start()
  def start_link({bot, channel, is_mod, conn}) do
    GenServer.start_link(__MODULE__, {bot, channel, is_mod, conn},
      name: module_name(bot, channel),
      hibernate_after: @hibernate_after_ms
    )
  end

  @doc """
  Stop the message server. Usually because of a `PART`.
  """
  @spec stop(module(), String.t()) :: :ok
  def stop(bot, channel) do
    module_name(bot, channel) |> GenServer.stop()
  end

  @doc """
  Stop the message server. Usually because of a `PART`.
  """
  @spec stop(module()) :: :ok
  def stop(name) do
    GenServer.stop(name)
  end

  @doc """
  Add a command to the outbound message queue.
  """
  @spec add_command(module(), String.t(), String.t()) :: :ok
  def add_command(bot, channel, command) do
    module_name(bot, channel) |> GenServer.cast({:add, {:cmd, command}})
  end

  @doc """
  Add a command to the outbound message queue.
  """
  @spec add_command(module(), String.t()) :: :ok
  def add_command(name, command) do
    GenServer.cast(name, {:add, {:cmd, command}})
  end

  @doc """
  Add a message to the outbound message queue.
  """
  @spec add_message(module(), String.t(), String.t()) :: :ok
  def add_message(bot, channel, message) do
    module_name(bot, channel) |> GenServer.cast({:add, {:msg, message}})
  end

  @doc """
  Add a message to the outbound message queue.
  """
  @spec add_message(module(), String.t()) :: :ok
  def add_message(name, message) do
    GenServer.cast(name, {:add, {:msg, message}})
  end

  @doc """
  Update the mod status of the bot for the channel.
  """
  def update_mod_status(name, is_mod) do
    GenServer.cast(name, {:update_mod_status, is_mod})
  end

  @doc """
  Generate the bot and channel specific module name.
  """
  @spec module_name(module(), String.t()) :: module()
  def module_name(bot, "#" <> channel) do
    module_name(bot, channel)
  end

  def module_name(bot, channel) do
    Module.concat([bot, String.capitalize(channel), "MessageServer"])
  end

  @doc """
  Generate the bot and channel specific module name.
  """
  @spec supervisor_name(module()) :: module()
  def supervisor_name(bot) do
    Module.concat([bot, "MessageServerSupervisor"])
  end

  # ----------------------------------------------------------------------------
  # GenServer callbacks
  # ----------------------------------------------------------------------------

  @doc """
  Invoked when the server is started. `start_link/3` will block until it
  returns.
  """
  @impl GenServer
  def init({bot, channel, is_mod, conn}) do
    state = %{
      bot: bot,
      channel: channel,
      conn: conn,
      rate: if(is_mod, do: @mod_rate_ms, else: @default_rate_ms),
      queue: :queue.new(),
      timer_ref: nil
    }

    Logger.info("[#{module_name(bot, channel)}] [#{state.channel}] STARTING @ #{state.rate}ms...")

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

  # Change the message rate when the moderator status changes.
  def handle_cast({:update_mod_status, is_mod}, state) do
    {:noreply, %{state | rate: if(is_mod, do: @mod_rate_ms, else: @default_rate_ms)}}
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
  defp send_message(:msg, message, conn, channel), do: Client.say(conn, channel, message)
end
