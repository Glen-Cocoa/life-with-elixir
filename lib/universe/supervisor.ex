defmodule Universe.Supervisor do
  use DynamicSupervisor

  def start do
    start_link()
  end

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child do
    child_spec = [
      %{
        id: Universe,
        start: {Universe, :start_link, []}
      },
      %{
        id: Cell.Supervisor,
        start: {Cell.Supervisor, :start_link, []},
        type: :supervisor
      },
      %{
        id: Registry,
        start: {Registry, :start_link, []},
        type: :supervisor
      }
    ]

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def init(_) do
    # :one_for_one strategy means that children will be started immediately
    # upon failure, the failed child will be restarted
    DynamicSupervisor.init(strategy: :one_for_one)
  end

end
