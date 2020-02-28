use Mix.Config

config :clecodes_ex, ClecodesExWeb.Endpoint,
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json",
  version: Application.spec(:clecodes_ex, :vsn)

  config :clecodes_ex, ClecodesExWeb.Repo,
    adapter: Ecto.Adapters.Postgres,
    show_sensitive_data_on_connection_error: true

config :logger,
  level: :info,
  handle_sasl_reports: true,
  handle_otp_reports: true
