defmodule Cell do
  use GenServer

  import Enum, only: [map: 2, filter: 2]

  # offset from current position - way to access each neighoring cell
  @offsets [
    {-1, -1}, { 0, -1}, { 1, -1},
    {-1,  0},           { 1,  0},
    {-1,  1}, { 0,  1}, { 1,  1},
  ]

  # required by GenServer - default implementation
  def init(init_arg) do
    {:ok, init_arg}
  end

  # starts link from Cell module (GenServer?)
  # starts GenServer process linked to current process
  # initializes process and passes 2nd arg (position)
  # what is the role of the tuple -- name: {:via, Registry, {Cell.Registry, position}} ?
  def start_link(position) do
    GenServer.start_link(__MODULE__, position, name: {
      :via, Registry, {Cell.Registry, position}
    })
  end

  # tells supervisor which cells to terminate
  def reap(process) do
    Supervisor.terminate_child(Cell.Supervisor, process)
  end

  # tells supervisor which cells to start
  def sow(position) do
    Supervisor.start_child(Cell.Supervisor, [position])
  end

  # advances to next frame
  def tick(process) do
    GenServer.call(process, {:tick})
  end

  # asks Genserver to call count_neighbors fx and returns result
  def count_neighbors(process) do
    GenServer.call(process, {:count_neighbors})
  end

  # calls the registry to look up current cell to pull out pid
  # filters for only living cells
  # returns first item from resulting list
  def lookup(position) do
    Cell.Registry
    |> Registry.lookup(position)
    # what is this anonymous fx syntax? declaring two fx heads inline?
    |> Enum.map(fn
      {pid, _value} -> pid
      nil -> nil
    end)
    |> Enum.filter(&Process.alive?/1)
    |> List.first
  end

  # handler for each tick event
  # counts neighbors of current position of cell (self?)
  # to reap if not 2 or 3 neighbors
  # to sow is cells that should become alive
  # sends reply of to reap and sow with current position
  def handle_call({:tick}, _from, position) do
    to_reap = position
    |> do_count_neighbors
    #cleaner way than piping into a case?
    |> case do
      2 -> []
      3 -> []
      _ -> [self()]
    end

    to_sow = position
    |> neighboring_positions
    |> keep_dead
    |> keep_valid_children

    {:reply, {to_reap, to_sow}, position}
  end

  # handles count_neighbors event
  # returns tuple with count of neighbors and current position
  def handle_call({:count_neighbors}, _from, position) do
    {:reply, do_count_neighbors(position), position}
  end

  # takes a position and returns the number of live neighbors
  def do_count_neighbors(position) do
    position
    |> neighboring_positions
    |> keep_live
    |> length
  end

  # returns map of current position with all neighbors
  def neighboring_positions({x,y}) do
    @offsets
    |> map(fn {dx, dy} -> {x + dx, y + dy} end)
  end

  # takes position with neighbors and filters for those that should be kept alive
  def keep_live(positions), do: filter(positions, &(lookup(&1) != nil))

  # takes position with neighbors and filters for those that should be kept dead
  def keep_dead(positions), do: filter(positions, &(lookup(&1) == nil))

  # returns list (enum?) of children that are valid - meaning having 3 neighbors
  def keep_valid_children(positions) do
    positions
    |> filter(&(do_count_neighbors(&1) == 3))
  end

end
