defmodule BinanceMarketsBot.Client do
  use WebSockex

  def start_link(state) do
    WebSockex.start_link("wss://stream.binance.com:9443/ws/!ticker@arr", __MODULE__, state, debug: [:trace])
  end
end