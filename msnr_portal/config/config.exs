# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :msnr_portal, MsnrPortalWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AIQ1fnlfr+0thtPLgOdNHh3dPxxSrrTPBDdVxowlV3AkBzHhl3o293mt12DBU6pn",
  render_errors: [view: MsnrPortalWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MsnrPortal.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "G9J3uvec"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
