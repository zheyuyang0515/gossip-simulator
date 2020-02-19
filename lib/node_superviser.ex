defmodule NodeSupervisor do
  use DynamicSupervisor
  def start_link() do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  @spec init(:no_args) ::
          {:ok,
           %{
             extra_arguments: [any],
             intensity: non_neg_integer,
             max_children: :infinity | non_neg_integer,
             period: pos_integer,
             strategy: :one_for_one
           }}
  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add(i) do
    {:ok, pid} = DynamicSupervisor.start_child(__MODULE__, {NodeServer, i})
    GenServer.cast(pid, {:arg_s, i})
    pid
  end
end
