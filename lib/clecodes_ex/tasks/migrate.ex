defmodule ClecodesEx.Tasks.Migrate do
  alias Distillery.Releases.Config.Providers
  @moduledoc false

  def migrate(_args) do
    require Logger

    # Configure
    Providers.Elixir.init(["${RELEASE_ROOT_DIR}/etc/config.exs"])
    repo_config = Application.get_env(:distillery_example, ClecodesEx.Repo)
    repo_config = Keyword.put(repo_config, :adapter, Ecto.Adapters.Postgres)

    repo_config
      |> inspect()
      |> Logger.debug()

    Application.put_env(:distillery_example, ClecodesEx.Repo, repo_config)

    # Start requisite apps
    IO.puts "==> Starting applications..."
    for app <- [:crypto, :ssl, :postgrex, :ecto, :ecto_sql] do
      {:ok, res} = Application.ensure_all_started(app)
      IO.puts "==> Started #{app}: #{inspect res}"
    end

    # Start the repo
    IO.puts "==> Starting repo"
    {:ok, _pid} = ClecodesEx.Repo.start_link(pool_size: 2, log: :debug, log_sql: true)

    # Run the migrations for the repo
    IO.puts "==> Running migrations"
    priv_dir = Application.app_dir(:distillery_example, "priv")
    migrations_dir = Path.join([priv_dir, "repo", "migrations"])

    opts = [all: true]
    pool = ClecodesEx.Repo.config[:pool]
    if function_exported?(pool, :unboxed_run, 2) do
      pool.unboxed_run(ClecodesEx.Repo, fn -> Ecto.Migrator.run(ClecodesEx.Repo, migrations_dir, :up, opts) end)
    else
      Ecto.Migrator.run(ClecodesEx.Repo, migrations_dir, :up, opts)
    end

    # Shut down
    :init.stop()
  end
end
