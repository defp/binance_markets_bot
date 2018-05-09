defmodule BinanceMarketsBot.Telegram do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: :telegram)
  end

  defp format_change(change) when change > 0,
    do: "+#{:erlang.float_to_binary(change, decimals: 2)}%"

  defp format_change(change) when change == 0,
    do: "=#{:erlang.float_to_binary(change, decimals: 2)}%"

  defp format_change(change) when change < 0,
    do: "#{:erlang.float_to_binary(change, decimals: 2)}%"

  defp format_price(price) do
    price |> :erlang.float_to_binary(decimals: 2) |> String.pad_trailing(10)
  end

  defp format_coin_name(name) do
    name |> String.replace("usdt", "") |> String.upcase() |> String.pad_trailing(5)
  end

  def format_markdown(data) do
    text =
      data
      |> Enum.map(fn info ->
        change = format_change((info["c"] - info["o"]) / info["o"] * 100)
        coin_name = format_coin_name(info["s"])
        price = format_price(info["c"])
        ~s(#{coin_name} $#{price} #{change}\n)
      end)
      |> Enum.join("")

    "*USDT*\n```\n#{text}```"
  end

  # callback
  def init(state) do
    {:ok, state}
  end

  def handle_cast({:send, data}, state) do
    coins = [
      "btc",
      "eth"
    ]

    ticker_statistics = Poison.decode!(data)
    ticker_statistics_map = Enum.into(ticker_statistics, %{}, fn m -> {m["s"], m} end)
    result =
      coins
      |> Enum.map(fn c -> String.upcase("#{c}usdt") end)
      |> Enum.map(fn symbol -> Map.get(ticker_statistics_map, symbol) end)
      
    Logger.debug(inspect(result))
    text = format_markdown(result)
    Logger.info("markdown #{text}")
    {:noreply, state}
  end
end
