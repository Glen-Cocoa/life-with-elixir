defmodule Universe do
  use GenServer

  # this import allows us to call map() instead of Enum.map()
  import Enum, only: [map: 2, reduce: 3]

  # entrypoint?
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # required by GenServer - default implementation
  def init(init_arg) do
    {:ok, init_arg}
  end

  # behavior - ?calls Universe.handle_call? when Genserver receives a {:tick}
  def tick do
    GenServer.call(__MODULE__, {:tick})
  end

  # when Universe.Supervisor emits :tick event, this fx is called
  # composes together the pieces to determine what effects should occur
  def handle_call({:tick}, _from, []) do
    get_cells()
    |> tick_each_process
    |> wait_for_ticks
    |> reduce_ticks
    |> reap_and_sow
    {:reply, :ok, []}
  end

  # asks Cell.Supervisor for list of child processes
  defp get_cells, do: Cell.Supervisor.children

  # takes list of cells/child processes and spawns a process to tick each Cell
  defp tick_each_process(processes) do
    map(processes, &(Task.async(fn -> Cell.tick(&1) end)))
  end

  # awaits for the completion of each :tick process started by tick_each_process
  defp wait_for_ticks(asyncs) do
    map(asyncs, &Task.await/1)
  end

  # reduces over list of ticks, accumulating starting with a tuple/2 containing empty lists
  # calls accumulate_ticks for each tick
  # returns a tuple with a list of cells to be {reaped, sown}
  defp reduce_ticks(ticks), do: reduce(ticks, {[], []}, &accumulate_ticks/2)

  # accumulates tuple/2 with list of cells to reap and sow
  defp accumulate_ticks({reap, sow}, {acc_reap, acc_sow}) do
    {acc_reap ++ reap, acc_sow ++ sow}
  end

  # calls reap or sow over corresponding lists
  # Cell module will terminate or start the relevant child processes
  def reap_and_sow({to_reap, to_sow}) do
    map(to_reap, &Cell.reap/1)
    map(to_sow, &Cell.sow/1)
  end
end
