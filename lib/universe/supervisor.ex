defmodule Universe.Supervisor do
  use Supervisor

  def start(_type, _args) do
    start_link()
  end

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      # specifies Universe as worker module and calls Universe.start_link with arg "[]"
        # TODO: Update deprecated method
      worker(Universe, []),
      # specifies Cell.Supervisor as sv module and calls Cell.Supervisor.start_link with arg "[]"

        # TODO: Update deprecated method
      supervisor(Cell.Supervisor, []),
        # TODO: Update deprecated method
      supervisor(Registry, [:unique, Cell.Registry])
    ]

    # :one_for_one strategy means that children will be started immediately
    # upon failure, the failed child will be restarted
      # TODO: Update deprecated method
    supervise(children, strategy: :one_for_one)
  end

end
