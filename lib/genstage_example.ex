defmodule GenstageExample do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(GenstageExample.Repo, []),
      worker(GenstageExample.Producer, []),
    ]
    consumers = for id <- 1..(System.schedulers_online * 12) do
                              # helper to get the number of cores on machine
                  worker(GenstageExample.Consumer, [], id: id)
                end

    opts = [strategy: :one_for_one, name: GenstageExample.Supervisor]
    Supervisor.start_link(children ++ consumers, opts)
  end
end
