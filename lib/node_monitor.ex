defmodule NodeMonitor do
  use GenServer
  def init({node_sum, converage_remain, start_time}), do: {:ok, {node_sum, converage_remain, start_time, node_sum}}
  def start_link({node_sum, converage_remain, start_time}) do
    #IO.inspect(converage_remain)
    GenServer.start_link(__MODULE__, {node_sum, converage_remain, start_time}, name: __MODULE__)
  end
  def handle_cast({:finished, pid}, {node_sum, converage_remain, start_time, all}) do
    #IO.inspect(all * 0.1)
    if Enum.member?(converage_remain, pid) == true do
      converage_remain = List.delete(converage_remain, pid)
      node_sum = length(converage_remain)
      #IO.inspect({"Active nodes remaining", node_sum})
      if node_sum <= 0 do
        #IO.puts("123husjkdhnjkashdkas")
        end_time = System.monotonic_time(:microsecond)
        time_consumption = end_time - start_time
        IO.puts("Time Consumption: " <> to_string(time_consumption) <> "us = " <> to_string(div(time_consumption, 1000)) <> "ms.")
        System.halt(0)
      end
      {:noreply, {node_sum, converage_remain, start_time, all}}
    else
      {:noreply, {node_sum, converage_remain, start_time, all}}
    end
  end

  def handle_cast({:first}, {node_sum, converage_remain, start_time, all}) do
    converage_remain = converage_remain - 1
    #IO.puts(converage_remain)
    if converage_remain == 0 do
      end_time = System.monotonic_time(:microsecond)
      time_consumption = end_time - start_time
      IO.puts("Time Consumption: " <> to_string(time_consumption) <> "us = " <> to_string(div(time_consumption, 1000)) <> "ms.")
      :init.stop
    end
    {:noreply, {node_sum, converage_remain, start_time, all}}
  end
  def sendFinished(pid) do
    GenServer.cast(__MODULE__, {:finished, pid})
  end
  def sendReceived do
    GenServer.cast(__MODULE__, {:first})
  end
end
