defmodule ClecodesEx.Repo do
  use Ecto.Repo,
    otp_app: :clecodes_ex,
    adapter: Ecto.Adapters.Postgres
end
