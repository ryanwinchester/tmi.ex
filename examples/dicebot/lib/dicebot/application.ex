defmodule Dicebot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      :dicebot
      |> Application.fetch_env!(:bots)
      |> Enum.map(&{TMI.Supervisor, &1})

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dicebot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
