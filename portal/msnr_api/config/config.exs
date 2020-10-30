# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :msnr_api,
  ecto_repos: [MsnrApi.Repo]

# Configures the endpoint
config :msnr_api, MsnrApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "GSE1WWPCglFC+6hRJmcbaDJEEJGiyow160GF11IgaPQcwz1xYSuzBFJHHyZRVAFZ",
  render_errors: [view: MsnrApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: MsnrApi.PubSub,
  live_view: [signing_salt: "B5MEouqh"]


config :token,
  refresh_token_expiration: 604800, #7 dana
  access_token_expiration: 1800, #30 minua
  secure_cookie: false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :cors_plug,
  origin: ["http://localhost:8080"],
  methods: ["GET", "POST"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
