# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :wingman, Wingman.Media,
  public_path: "/uploads",
  upload_path: Path.expand("../priv/uploads", __DIR__),
  chunk_path: Path.expand("../priv/upload_chunks", __DIR__)

# 存储配置
config :wingman, Wingman.Storage,
  public_path: "/storage",
  root_path: Path.expand("../priv/storage/root", __DIR__),
  tmp_path: Path.expand("../priv/storage/tmp", __DIR__)

config :wingman,
  ecto_repos: [Wingman.Repo]

# Configures the endpoint
config :wingman, WingmanWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TpEKFgtoswOID+v8QOCbHZAz1cw0E8TzdJJUJsKaJ/Kt37mV9NSlTiDwqv+RQPZd",
  render_errors: [view: WingmanWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Wingman.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
