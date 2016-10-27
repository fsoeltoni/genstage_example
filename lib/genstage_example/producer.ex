defmodule GenstageExample.Producer do
  alias Experimental.GenStage
  use GenStage

  @name __MODULE__

  def start_link do
    GenStage.start_link(__MODULE__, 0, name: @name)
  end

  def enqueue(module, function, args) do
    GenstageExample.Task.enqueue("waiting", :erlang.term_to_binary({module, function, args}))
    Process.send(@name, :enqueued, [])
    :ok
  end

  def init(counter) do
    {:producer, counter}
  end

  def handle_cast(:enqueued, state) do
    serve_jobs(state)
  end

  def handle_demand(demand, state) do
    serve_jobs(demand + state)
  end

  def handle_info(:enqueued, state) do
    {count, events} = GenstageExample.Task.take(state)
    {:noreply, events, state - count}
  end

  def serve_jobs limit do
    {count, events} = GenstageExample.Task.take(limit)
    Process.send_after(@name, :enqueued, 60_000)
    {:noreply, events, limit - count}
  end
end
