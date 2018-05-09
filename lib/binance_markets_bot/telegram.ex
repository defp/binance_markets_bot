defmodule BinanceMarketsBot.Telegram do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: :telegram)
  end

  defp format_change(change) when is_binary(change) do
    {change, _} = Float.parse(change)
    format_change(change)
  end

  defp format_change(change) when change > 0,
    do: "+#{:erlang.float_to_binary(change, decimals: 2)}%"

  defp format_change(change) when change == 0,
    do: "=#{:erlang.float_to_binary(change, decimals: 2)}%"

  defp format_change(change) when change < 0,
    do: "#{:erlang.float_to_binary(change, decimals: 2)}%"

  defp format_coin_name(name) do
    cond do
      String.ends_with?(name, "USDT") ->
        name |> String.replace("USDT", "")

      String.ends_with?(name, "BTC") ->
        name |> String.replace("BTC", "")
    end
    |> String.upcase()
    |> String.pad_trailing(5)
  end

  defp format_price(price, decimals) do
    {price, _} = Float.parse(price)
    price |> :erlang.float_to_binary(decimals: decimals) |> String.pad_trailing(12)
  end

  def format_markdown(data) do
    usdt_data = data[:usdt_data]
    btc_data = data[:btc_data]

    usdt_text =
      usdt_data
      |> Enum.map(fn info ->
        coin_name = format_coin_name(info["s"])
        price = format_price(info["c"], 3)
        change = format_change(info["P"])
        ~s(#{coin_name} $#{price} #{change}\n)
      end)
      |> Enum.join("")

    btc_text =
      btc_data
      |> Enum.map(fn info ->
        coin_name = format_coin_name(info["s"])
        price = format_price(info["c"], 9)
        change = format_change(info["P"])
        ~s(#{coin_name} #{price}  #{change}\n)
      end)
      |> Enum.join("")

    "*USDT*\n```\n#{usdt_text}```\n*BTC*\n```\n#{btc_text}```"
  end

  # callback
  def init(state) do
    {:ok, state}
  end

  def handle_cast({:send, data}, state) do
    options = [parse_mode: "Markdown", disable_notification: true]

    case Nadia.send_message("@binance_markets", format_markdown(data), options) do
      {:ok, _result} ->
        Logger.info("send_message successful")

      {:error, %Nadia.Model.Error{reason: reason}} ->
        Logger.error("send_message error #{reason}")
    end

    {:noreply, state}
  end
end
