defmodule TMI do
  @moduledoc """
  TMI is a library for connecting to Twitch chat with Elixir.

  See the [README](https://hexdocs.pm/tmi/readme.html) for more details.
  """
  use GenServer

  alias TMI.Client
  alias TMI.Conn

  # ----------------------------------------------------------------------------
  # Public API
  # ----------------------------------------------------------------------------

  @doc """
  Start the TMI supervisor process.
  """
  @spec supervisor_start_link(keyword) :: {:ok, pid}
  def supervisor_start_link(config) do
    TMI.Supervisor.start_link(config)
  end

  @doc """
  Start the TMI process.
  """
  @spec start_link(Conn.t() | keyword) :: {:ok, pid}
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @doc """
  Send a chat message.
  """
  @spec message(String.t(), String.t()) :: :ok
  def message(chat, message) do
    GenServer.cast(__MODULE__, {:message, chat, message})
  end

  @doc """
  Send a whisper message to a user.
  """
  @spec whisper(String.t(), String.t()) :: :ok
  def whisper(user, message) do
    GenServer.cast(__MODULE__, {:whisper, user, message})
  end

  @doc """
  Send an action message to a chat.
  """
  @spec action(String.t(), String.t()) :: :ok
  def action(chat, message) do
    GenServer.cast(__MODULE__, {:action, chat, message})
  end

  @doc """
  Determine if the provided client process has an open connection to a server.
  """
  @spec is_connected?() :: true | false
  def is_connected? do
    GenServer.call(__MODULE__, :is_connected?)
  end

  @doc """
  Determine if the provided client is logged on to a server.
  """
  @spec is_logged_on?() :: true | false
  def is_logged_on? do
    GenServer.call(__MODULE__, :is_logged_on?)
  end

  @doc """
  Get a list of users in the provided chat.

  Notes:
   * requires `membership` capability to show more than yourself
   * requires you are in the chat or an error will be raised

  """
  @spec chat_users(chat :: String.t()) :: list(String.t()) | [] | {:error, atom}
  def chat_users(chat) do
    GenServer.call(__MODULE__, {:chat_users, chat})
  end

  @doc """
  Determine if a user is present in the provided chat.

  Notes:
   * requires `membership` capability to show more than yourself
   * requires you are in the chat or an error will be raised

  """
  @spec chat_has_user?(chat :: String.t(), user :: String.t()) :: true | false | {:error, atom}
  def chat_has_user?(chat, user) do
    GenServer.call(__MODULE__, {:chat_has_user?, chat, user})
  end

  # ----------------------------------------------------------------------------
  # GenServer Callbacks
  # ----------------------------------------------------------------------------

  @impl true
  def init(%Conn{} = conn) do
    {:ok, conn}
  end

  def init(config) do
    config
    |> build_conn()
    |> init()
  end

  @impl true
  def handle_cast({:message, chat, message}, conn) do
    Client.message(conn, chat, message)
    {:noreply, conn}
  end

  def handle_cast({:whisper, user, message}, conn) do
    Client.whisper(conn, user, message)
    {:noreply, conn}
  end

  def handle_cast({:action, chat, message}, conn) do
    Client.action(conn, chat, message)
    {:noreply, conn}
  end

  @impl true
  def handle_call(:is_connected?, _from, conn) do
    result = Client.is_connected?(conn)
    {:reply, result, conn}
  end

  def handle_call(:is_logged_on?, _from, conn) do
    result = Client.is_logged_on?(conn)
    {:reply, result, conn}
  end

  def handle_call({:chat_users, chat}, _from, conn) do
    result = Client.chat_users(conn, chat)
    {:reply, result, conn}
  end

  def handle_call({:chat_has_user?, chat, user}, _from, conn) do
    result = Client.chat_has_user?(conn, chat, user)
    {:reply, result, conn}
  end

  # ----------------------------------------------------------------------------
  # Helpers
  # ----------------------------------------------------------------------------

  @doc false
  def build_conn(config) do
    user = Keyword.fetch!(config, :user)
    pass = Keyword.fetch!(config, :pass)
    chats = Keyword.get(config, :chats, [])
    caps = Keyword.get(config, :capabilities, ['membership'])

    {:ok, client} = Client.start_link!()

    Conn.new(client, user, pass, chats, caps)
  end
end
