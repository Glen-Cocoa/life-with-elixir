defmodule Universe.Supervisor do
  use DynamicSupervisor

  def start(_type, _args) do
    start_link()
  end

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child() do
    children = [
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

    DynamicSupervisor.start_child(__MODULE__, children)
  end

  def init(_) do
    # specifies Universe as worker module and calls Universe.start_link with arg "[]"
    children = [
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

    # :one_for_one strategy means that children will be started immediately
    # upon failure, the failed child will be restarted
    DynamicSupervisor.init(strategy: :one_for_one)
  end

end
