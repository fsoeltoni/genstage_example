defmodule GenstageExample.Producer do
  alias Experimental.GenStage
  use GenStage

  import Ecto.Query
  import GenstageExample.Repo

  def start_link do
    GenStage.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def init(counter) do
    {:producer, counter}
  end

  def handle_demand(demand, state) when demand > 0 do
    limit = demand + state
    {count, events} = take(limit)
    {:noreply, events, limit - count}
  end

  def handle_info(:data_inserted, state) do
    limit = state
    {count, events} = take(limit)
    {:noreply, events, limit - count}
  end

  def take demand do
    {:ok, {count, events}} =
      GenstageExample.Repo.transaction fn ->
        GenstageExample.Repo.update_all by_ids(task_ids(demand)),
                                        [set: [status: "running"]],
                                        [returning: [:id, :payload]]
      end
    {count, events}
  end

  def task_ids demand do
    demand
    |> waiting
    |> GenstageExample.Repo.all
  end

  def by_ids task_ids do
    from t in "tasks", where: t.id in ^task_ids
  end

  def waiting demand do
    from t in "tasks",
      where: t.status == "waiting",
      limit: ^demand,
      select: t.id,
      lock: "FOR UPDATE SKIP LOCKED"
  end
end
