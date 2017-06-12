defmodule Overcharge do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications


  def start(_type, _args) do
    import Supervisor.Spec

    :ets.new(:wordlist, [:named_table])   ## create new ets table
    {:ok, wordlist} = File.read!("wordlist.json") |> Poison.decode
    true = :ets.insert(:wordlist, {:easy, wordlist |> Map.get("fours")})
    true = :ets.insert(:wordlist, {:mid, wordlist |> Map.get("sixes")})
    true = :ets.insert(:wordlist, {:hard, wordlist |> Map.get("tens")})



    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Overcharge.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Overcharge.Endpoint, []),
      worker(Cachex, [:overcharge_cache, []]),
      #worker(Overcharge.BotFetcher, []),
      # Start your own worker by calling: Overcharge.Worker.start_link(arg1, arg2, arg3)
      # worker(Overcharge.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Overcharge.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Overcharge.Endpoint.config_change(changed, removed)
    :ok
  end
end
