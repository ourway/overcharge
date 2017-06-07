defmodule Overcharge.Mixfile do
  use Mix.Project

  def project do
    [app: :overcharge,
     version: "0.0.2",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Overcharge, []},
     applications: [:phoenix, :phoenix_pubsub, :coherence, :sitemap, :ex_cron, :phoenix_live_reload,
                    :jalaali, :exml, :calendar, :cachex, :mailman, :ssl, :floki, :mochiweb,
                    :phoenix_html, :cowboy, :nadia, :logger, :gettext,:httpoison,
                    :phoenix_ecto, :postgrex, :earmark]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.1"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:postgrex, ">= 0.0.0"},
     {:mailman, "~> 0.3.0"},
     {:html_sanitize_ex, "~> 1.3.0"},
     {:coherence, "~> 0.3"},
     {:exrm, "~> 1.0.8"},
     {:eiconv, github: "zotonic/eiconv"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0"},
     {:gettext, "~> 0.11"},
     {:floki, "~> 0.17.2"},
     {:sitemap, "~> 0.9.1"},
     {:nadia, "~> 0.4.2"},
     {:earmark, "~> 1.2.2"},
     {:poison, "~> 3.1", override: true},
     {:calendar, "~> 0.16.1"},
     {:jalaali, "~> 0.1.1"},
     {:httpoison, "~> 0.11.0"},
     {:exml, "~>0.1.0"},
     {:ex_cron, "~> 0.0.3"},
     {:cachex, "~> 2.0"},
     {:cowboy, "~> 1.0"}]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
