defmodule Cell.Supervisor do
  use DynamicSupervisor

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(module, position) do
    child_spec = %{
      id: module,
      start: {module, :start_link, position}
    }
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def init([]) do
    children = [
    # TODO: Update deprecated method
      # worker(Cell, [])
      %{
        id: Cell,
        start: {Cell, :start_link}
      }
    ]
    # simple_one_for_one strategy means
    # children will be added & removed to the supervision tree dynamically
    # children will be Cell worker processes (deprecated?)
    # :transient means when Cell process terminates with :normal or :shutdown it will not be restarted
    # Supervisor will restart a process dying with any other message

      # TODO: Update deprecated method
    # supervise(children, strategy: :simple_one_for_one, restart: :transient)
    DynamicSupervisor.start_link(children, strategy: :simple_one_for_one)
    # Supervisor.start_link(children, strategy: :simple_one_for_one, restart: :transient)
  end

  # return enum of pids of all children being supervised
  def children do
    Cell.Supervisor
    |> DynamicSupervisor.which_children
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end

end
