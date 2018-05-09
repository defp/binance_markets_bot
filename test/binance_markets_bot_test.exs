defmodule BinanceMarketsBotTest do
  use ExUnit.Case
  doctest BinanceMarketsBot

  test "greets the world" do
    assert BinanceMarketsBot.hello() == :world
  end
end
