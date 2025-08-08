defmodule MyHeadsUp.Repo do
  use Ecto.Repo,
    otp_app: :my_heads_up,
    adapter: Ecto.Adapters.Postgres
end
