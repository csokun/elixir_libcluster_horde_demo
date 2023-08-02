# Elixir Distributed & Fault Tolerance Demo

Pre-requisites:
- Erlang & Elixir installed
- Clone the project and you ready to go

Demo

- Start multiple nodes using `iex --sname <NAME> -S mix` e.g `iex --sname node1 -S mix`
- Start greeting process from any node

```elixir
# from node1 start a child process
Horde.DynamicSupervisor.start_child(MixApp1.DistributedSupervisor, {MixApp1.Greeting, "agent1"})

# from node2
MixApp1.Greeting.say("agent1", "hello")
```

## Fault Tolerance

Node1 goes down:
- Kill node1 `CTRL+C`
- From node2 re-run `MixApp1.Greeting.say("agent1", "hello")`

Node1 backup & Node2 go down:
- Start node1 `iex --sname node1 -S mix`
- Kill node2 `CTRL+C`
- From node1 run `MixApp1.Greeting.say("agent1", "hello")`

