defmodule BinanceMarketsBot.Periodically do
  use GenServer
  import Process

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    schedule_work(args[:second])
    {:ok, args}
  end

  def handle_info(:telegram, state) do
    schedule_work(state[:second])
    send(whereis(:binance), :telegram)
    {:noreply, state}
  end

  defp schedule_work(second) do
    send_after(self(), :telegram, second * 1000)
  end
end
