# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :overcharge,
  ecto_repos: [Overcharge.Repo]

# Configures the endpoint
config :overcharge, Overcharge.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Vf4cv7mOnPEJguFJKxMqSCT5nJ6vSHhcRMRKU8vwkiFVIXKdyV82dgbXxGFjZKw3",
  render_errors: [view: Overcharge.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Overcharge.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: Overcharge.User,
  repo: Overcharge.Repo,
  module: Overcharge,
  logged_out_url: "/",
  email_from_name: "Chargell Sales",
  email_from_email: "sales@chargell.ir",
  opts: [:confirmable, :rememberable, :registerable, :invitable, :authenticatable, :recoverable, :lockable, :trackable, :unlockable_with_token]

config :coherence, Overcharge.Coherence.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: "your api key here"
# %% End Coherence Configuration %%
