
defmodule NodeServer do
  use GenServer
  def init(:no_args), do: {:ok, 0}
  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args)
  end
  def handle_cast({:arg_s, s}, count) do
    w = 1
    {:noreply, {s, w, 0, count}}
  end
  def handle_cast({:neighbor, nodes}, {s, w, sum, count}) do
    #IO.inspect({"nodes", self(), nodes})
    #IO.inspect({"server", self(), nodes})
    #IO.inspect(nodes)
    nodes = Enum.reject(nodes, fn x -> x == nil end)
    #IO.inspect(nodes)
    {:ok, sPid} = NodeSender.start_link({nodes, s, w})
    #IO.inspect({"init", self(), s, w})
    if length(nodes) == 0 do
      #GenServer.cast(sPid, {:stop})
      #if no neighbor, then exit this process
      NodeMonitor.sendFinished(self())
    end
    {:noreply, {nodes, sum, count, sPid}}
  end
  def handle_cast({:send_sender}, {nodes, sum, count, sPid}) do
   # IO.inspect({"nodes", self(), nodes})
    Enum.map(nodes, fn node ->
      GenServer.cast(node, {:sender ,self()})
    end)
    {:noreply, {nodes, sum, count, sPid}}
  end
  def handle_cast({:sender, pid}, {nodes, sum, count, sPid}) do
    GenServer.cast(sPid, {:sender, pid})
    {:noreply, {nodes, sum, count, sPid}}
  end

  def handle_cast({:ps_start, _}, {nodes, sum, count, sPid}) do
    GenServer.cast(sPid, {:push_sum, self()})
    {:noreply, {nodes, sum, count + 1, sPid}}
  end

  def handle_cast({:push_sum, s, w, pid}, {nodes, sum, count, sPid}) do
    GenServer.cast(sPid, {:new_received, s, w, self(), pid})
   # if count == 0 do
     # GenServer.cast(sPid, {:push_sum, self()})
   # end
    {:noreply, {nodes, sum, count + 1, sPid}}
  end


  def handle_cast({:terminated, node}, {nodes, sum, count, sPid}) do
    GenServer.cast(sPid, {:terminated, node, self()})
    {:noreply, {nodes, sum, count, sPid}}
  end
  def handle_cast({:terminated_rumor, node}, {nodes, sum, count, sPid}) do
    GenServer.cast(sPid, {:terminated_rumor, node})
    {:noreply, {nodes, sum, count, sPid}}
  end
  def handle_cast({:rumor, info, pid}, {nodes, sum, count, sPid}) do
    #IO.inspect(count)
    if count < 10 do
      if count == 0 do
        GenServer.cast(sPid, {:rumor, info, self()})
      end
    else
      #if count == 10 do
        NodeMonitor.sendFinished(self())
        GenServer.cast(pid, {:terminated_rumor, self()})
      #else
        #if count > 10 do
          #GenServer.cast(pid, {:terminated, self()})
        #end
      #end
    end
    {:noreply, {nodes, sum, count + 1, sPid}}
  end
end
