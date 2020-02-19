defmodule Check do
  def checkExit(pid) do
    if Process.alive?(pid) do
      checkExit(pid)
    end
  end
end
[numNodes, topology, algorithm] = Enum.map_every(System.argv, 1, fn(arg) -> to_string(arg) end)
children = [
  %{
    id: NodeSupervisor,
    start: {NodeSupervisor, :start_link, []}
  }
]
Supervisor.start_link(children, strategy: :one_for_all)
nodes = []
nodes = nodes ++ Enum.map(0..String.to_integer(numNodes) - 1,  fn i ->
  NodeSupervisor.add(i);
end)
start_time = System.monotonic_time(:microsecond)
{:ok, mPid} = NodeMonitor.start_link({length(nodes), nodes, start_time})
Topologies.findNeighbor(topology, nodes)
Enum.map(nodes, fn node ->
  GenServer.cast(node, {:send_sender})
end)
case algorithm do
  "gossip" -> node = Enum.random(nodes)
  GenServer.cast(node, {:rumor, 1, self()})
  "push-sum" -> node = Enum.random(nodes)
  GenServer.cast(node, {:ps_start, self()})
end
Check.checkExit(mPid)
#IO.inspect(workers)
