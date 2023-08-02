defmodule MixApp1.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = [
      local: [
        strategy: Cluster.Strategy.LocalEpmd
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: MixApp1.ClusterSupervisor]]},
      {Horde.Registry, [name: MixApp1.DistributedRegistry, keys: :unique, members: :auto]},
      {Horde.DynamicSupervisor,
       [
         name: MixApp1.DistributedSupervisor,
         strategy: :one_for_one,
         shutdown: 10_000,
         members: :auto
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MixApp1.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
