# Life

## The Rules:
  - If a cell is dead, and has 3 living neighbors, it should become alive
  - If a cell is living and has 2 || 3 neighbors, it will remain alive
  - Any cell not matching above criteria should die/remain dead

to start the simulation, run `iex -S mix` and start call `Universe.Supervisor(_,_)` 
cell(s) can be added by calling `Cell.sow({x, y})`
observe the interaction of processes by calling `:observer.start`

## What is happening?

### Cells
Each "Cell" should is represented by a separate Elixir process, which is responsible for keeping track of it's own position {x, y}

Cells should be responsible for managing their own position, and must be able to find their neighbors and determine whether they should be alive or dead

### Cell.Supervisor
This supervises all dynamically added/removed Cell processes
- must be able to return information regarding current living Cell processes

### Universe
A parent process is necessary to manage & keep track of the existing cells/processes
This parent process should be responsible for telling each cell when it is time to update, or `:tick`

#### Universe.Supervisor
This is out top level supervisor - must be responsible for
- creating a single Universe process
- starting the Cell.Supervisor
- starting the Cell.Registry (?a way to keep track of existing cells?)

Derived from http://www.petecorey.com/blog/2017/02/06/playing-the-game-of-life-with-elixir-processes/?from=east5th.co
