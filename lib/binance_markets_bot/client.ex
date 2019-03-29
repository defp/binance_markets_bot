defmodule BinanceMarketsBot.Client do
  use WebSockex
  require Logger

  def start_link(state) do
    options = if Mix.env() == :dev, do: [debug: [:trace]], else: [socket_connect_timeout: 10000]
    options = Keyword.merge(options, name: :binance)
    ws_endpoint = "wss://stream.binance.com:9443/ws/!ticker@arr"
    WebSockex.start_link(ws_endpoint, __MODULE__, state, options)
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected!")
    {:ok, state}
  end

  def handle_frame({:text, msg}, state) do
    ticker_statistics = Poison.decode!(msg)
    state = Enum.into(ticker_statistics, state, fn m -> {m["s"], m} end)
    {:ok, state}
  end

  def handle_disconnect(%{reason: reason}, state) do
    Logger.info("Local close with reason: #{inspect(reason)}")
    {:reconnect, state}
  end

  def handle_info(:telegram, state) do
    usdt_coins = [
      "btcusdt",
      "adausdt",
      "ethusdt",
      "eosusdt",
      "bnbusdt",
      "ltcusdt",
      "neousdt",
      "xrpusdt",
      "xlmusdt",
      "qtumusdt",
      "bchsvusdt",
      "bchabcusdt"
    ]

    btc_coins = [
      "ethbtc",
      "adabtc",
      "aebtc",
      "etcbtc",
      "eosbtc",
      "xrpbtc",
      "ltcbtc",
      "xlmbtc",
      "dashbtc",
      "xmrbtc",
      "trxbtc"
    ]

    usdt_data =
      usdt_coins
      |> Enum.map(fn c -> Map.get(state, String.upcase(c)) end)

    btc_data =
      btc_coins
      |> Enum.map(fn c -> Map.get(state, String.upcase(c)) end)

    GenServer.cast(
      Process.whereis(:telegram),
      {:send, %{usdt_data: usdt_data, btc_data: btc_data}}
    )

    {:ok, state}
  end

  def terminate(reason, _state) do
    Logger.info("Local terminate with reason: #{inspect(reason)}")
    exit(:normal)
  end
end
