use Mix.Config

# iex --name a@127.0.0.1 -S mix
# iex --name b@127.0.0.1 -S mix
# iex --name c@127.0.0.1 -S mix
config :libcluster,
  topologies: [
    dev: [
      strategy: Cluster.Strategy.Epmd,
      config: [
        hosts: [
          :"a@127.0.0.1",
          :"b@127.0.0.1",
          :"c@127.0.0.1"
        ]
      ]
    ]
  ]
