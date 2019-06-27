defmodule Wingman.Repo do
  use Ecto.Repo,
    otp_app: :wingman,
    adapter: Ecto.Adapters.Postgres
end
