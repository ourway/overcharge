use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :overcharge, Overcharge.Endpoint,
  #http: [port: 4000],
  https: [port: 4444  ,
          otp_app: :overcharge,
          keyfile: "priv/keys/localhost.key",
          certfile: "priv/keys/localhost.cert"],
  debug_errors: false,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../", __DIR__)]]


# Watch static and templates for browser reloading.
config :overcharge, Overcharge.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :overcharge, Overcharge.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "overcharge_dev",
  hostname: "localhost",
  pool_size: 10



config :nadia,
  token: "396811502:AAGK-M5KH9yJBSzC72RiY6lC7OelWvh06Ws"  ##prod
  #token: "381106026:AAFOWEEkwc4HWgQLYtr0rTGBdPzYhSHsFsw"

