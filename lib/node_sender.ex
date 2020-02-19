defmodule NodeSender do
    use GenServer
    def init({neighbor, s, w}), do: {:ok, {neighbor, [], s, w, 0, []}}
    def start_link({neighbor, s, w}) do
      GenServer.start_link(__MODULE__, {neighbor, s, w})
    end
    def handle_cast({:sender, pid}, {neighbor, nodes, s, w, count, list}) do
      nodes = nodes ++ List.wrap(pid)
      #IO.inspect({my, pid})
      {:noreply, {neighbor, nodes, s, w, count, list}}
    end

    def handle_cast({:terminated_rumor, node}, {neighbor, nodes, s, w, count, list}) do
      neighbor = List.delete(neighbor, node)
      {:noreply, {neighbor, nodes, s, w, count, list}}
    end
    def handle_cast({:terminated, node, pid}, {neighbor, nodes, s, w, count, list}) do
      neighbor = List.delete(neighbor, node)
      #IO.inspect({"terminated", pid})
      if length(neighbor) <= 0 do
        #IO.inspect(pid)
        NodeMonitor.sendFinished(pid)
        Enum.map(nodes, fn node->
          GenServer.cast(node, {:terminated, pid})
        end)
       # nodes = nodes -- list
        {:noreply, {neighbor, [], 0, 1, 5, list}}
      else
        GenServer.cast(self(), {:push_sum, pid})
        {:noreply, {neighbor, nodes, s, w, count, list}}
      end
    end


    def handle_cast({:push_sum, pid}, {neighbor, nodes, s, w, count, list}) do
        if length(neighbor) == 0 || count >= 3 do
          NodeMonitor.sendFinished(pid)
          Enum.map(nodes, fn node->
            GenServer.cast(node, {:terminated, pid})
          end)
          {:noreply, {neighbor, nodes, 0, 1, 5, list}}
        else
         #Process.sleep(100)
          state = sendPushSum(s, w, neighbor, pid)
          if state == false do
            #IO.inspect(pid)
            NodeMonitor.sendFinished(pid)
            Enum.map(nodes, fn node->
              GenServer.cast(node, {:terminated, pid})
            end)
           # nodes = nodes -- list
            {:noreply, {neighbor, [], 0, 1, 5, list}}
          else
            {:noreply, {neighbor, nodes, s / 2, w / 2, count, list}}
          end
        end
    end

    def handle_cast({:new_received, recv_s, recv_w, pid, _}, {neighbor, nodes, s, w, count, list}) do
      #IO.inspect({pid, neighbor})
      if count < 3 do
        new_s = recv_s + s
        new_w = recv_w + w
        current = new_s / new_w
        last = s / w
        count = if abs(current - last) < :math.pow(10, -10) do
          count + 1
        else
          0
        end
        #IO.inspect({"recv", pid, count, current - last})
        GenServer.cast(self(), {:push_sum, pid})
        {:noreply, {neighbor, nodes, new_s, new_w, count, list}}
      else
        #IO.inspect(pid)
        NodeMonitor.sendFinished(pid)
        Enum.map(nodes, fn node->
          GenServer.cast(node, {:terminated, pid})
        end)
        #nodes = nodes -- list
        {:noreply, {neighbor, [], 0, 1, 5, list}}
      end
    end

    def handle_cast({:rumor, info, pid}, {neighbor, nodes, s, w, count, list}) do
      sendRumor(info, pid, neighbor)
      {:noreply, {neighbor, nodes, s, w, count, list}}
    end

    defp sendPushSum(s, w, neighbor, pid) do
      #IO.inspect(neighbor)
      if length(neighbor) > 0 do
        node = Enum.random(neighbor)
        GenServer.cast(node, {:push_sum, s / 2, w / 2, pid})
        #IO.inspect({"send", pid, node, neighbor})
        #GenServer.cast(self(), {:push_sum, pid})
        true
      else
        false
      end
    end

    defp sendRumor(info, pid, neighbor) do

      if length(neighbor) > 0 do
        node = Enum.random(neighbor)
        GenServer.cast(node, {:rumor, info, pid})
        GenServer.cast(self(), {:rumor, info, pid})
      else
        #if no neighbor exist, then exit the process
        GenServer.cast(pid, {:terminated_rumor, pid})
      end
    end
end
