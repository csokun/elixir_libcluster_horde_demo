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

  def say(name, word) do
    GenServer.call(via_tuple(name), {:say, word})
  end

  def init(name) do
    Process.flag(:trap_exit, true)
    {:ok, name}
  end

  def terminate(reason, _state) do
    IO.puts("terminated with reason: #{inspect(reason)}")
    :stop
  end

  def handle_call({:say, word}, _from, state) do
    {:reply, "Say, #{word} from #{state}", state}
  end

  defp via_tuple(name) do
    {:via, Horde.Registry, {MixApp1.DistributedRegistry, name}}
  end
end
