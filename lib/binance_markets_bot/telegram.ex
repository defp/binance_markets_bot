defmodule BinanceMarketsBot.Telegram do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: :telegram)
  end

  defp format_coin_name(name) do
    name |> String.replace("USDT", "") |> String.upcase() |> String.pad_trailing(5)
  end

  def format_markdown(data) do
    text =
      data
      |> Enum.map(fn info ->
        coin_name = format_coin_name(info["s"])
        ~s(#{coin_name} $#{info["c"]} #{info["P"]}\n)
      end)
      |> Enum.join("")

    "*USDT*\n```\n#{text}```"
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
