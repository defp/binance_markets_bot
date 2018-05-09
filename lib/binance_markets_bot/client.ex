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
    {:ok, state}
  end

  def handle_info(:telegram, state) do
    coins = [
      "btc",
      "eth"
    ]
    
    data =
      coins
      |> Enum.map(fn c -> Map.get(state, String.upcase("#{c}usdt")) end)

    pid = Process.whereis(:telegram)
    GenServer.cast(pid, {:send, data})
    {:ok, state}
  end

  def terminate(reason, _state) do
    Logger.info("Local terminate with reason: #{inspect(reason)}")
    exit(:normal)
  end
end
