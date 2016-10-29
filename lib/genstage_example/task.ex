defmodule GenstageExample.Task do
  def enqueue(status, payload) do
    GenstageExample.TaskDBInterface.insert_tasks(status, payload)
  end

  def update_status(id, status) do
    GenstageExample.TaskDBInterface.update_task_status(id, status)
  end

  def take(limit) do
    GenstageExample.TaskDBInterface.take_tasks(limit)
  end
end
