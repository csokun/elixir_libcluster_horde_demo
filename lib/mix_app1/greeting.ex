defmodule MixApp1.Greeting do
  use GenServer, restart: :transient

  def start_link(name) do
    case GenServer.start_link(__MODULE__, name, name: via_tuple(name)) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, _pid}} ->
        :ignore
    end
  end

  def start(name) do
    Horde.DynamicSupervisor.start_child(MixApp1.DistributedSupervisor, {__MODULE__, name})
  end

  def say(name, word) do
    GenServer.call(via_tuple(name), {:say, word})
  end

  def init(name) do
    Process.flag(:trap_exit, true)
    {:ok, %{name: name, served: 0}, {:continue, :load_state}}
  end

  def handle_continue(:load_state, state) do
    IO.puts("#{inspect(state)}")
    # retrieve state from Horde Registry
    case Horde.Registry.meta(MixApp1.DistributedRegistry, state.name) do
      {:ok, meta} ->
        IO.puts("state found #{inspect(meta)}")
        {:noreply, Map.merge(state, meta)}

      :error ->
        IO.puts("state not found")
        {:noreply, state}
    end
  end

  def terminate(reason, %{name: name} = state) do
    IO.puts("terminated with reason: #{inspect(reason)}")
    # Use Horde Registry meta, which is kept synchronized across a cluster using a CRDT
    Horde.Registry.put_meta(MixApp1.DistributedRegistry, name, state)
    # Give process a couple ms to sync up
    Process.sleep(500)
  end

  def handle_call({:say, word}, _from, %{name: name, served: served} = state) do
    state = %{state | served: served + 1}
    {:reply, "Say, #{word} from #{name} [served: #{state.served}]", state}
  end

  defp via_tuple(name) do
    {:via, Horde.Registry, {MixApp1.DistributedRegistry, name}}
  end
end
