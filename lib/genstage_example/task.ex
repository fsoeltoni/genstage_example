defmodule GenstageExample.Task do
  import Ecto.Query

  alias GenstageExample.Repo

  def update_status(id, status) do
    Repo.update_all by_ids([id]), set: [status: status]
  end

  def enqueue(status, payload) do
    Repo.insert_all "tasks", [
      %{status: status, payload: payload}
    ]
  end

  def take(limit) do
    {:ok, {count, events}} =
      Repo.transaction fn ->
        ids = Repo.all waiting(limit)
        Repo.update_all by_ids(ids), [set: [status: "running"]], [returning: [:id, :payload]]
      end
    {count, events}
  end

  defp by_ids(ids) do
    from t in "tasks", where: t.id in ^ids
  end

  defp waiting(limit) do
    from t in "tasks",
      where: t.status == "waiting",
      limit: ^limit,
      select: t.id,
      lock: "FOR UPDATE SKIP LOCKED"
  end
end
