defmodule BinanceMarketsBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    second =
      if System.get_env("second"), do: String.to_integer(System.get_env("second")), else: 10

    children = [
      {BinanceMarketsBot.Periodically, [second: second]},
      {BinanceMarketsBot.Client, %{}},
      {BinanceMarketsBot.Telegram, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BinanceMarketsBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
