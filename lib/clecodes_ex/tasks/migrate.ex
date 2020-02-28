defmodule ClecodesEx.Tasks.Migrate do
  alias Distillery.Releases.Config.Providers
  @moduledoc false

  def migrate(_args) do
    # Configure
    Providers.Elixir.init(["${RELEASE_ROOT_DIR}/etc/config.exs"])
    repo_config = Application.get_env(:distillery_example, ClecodesEx.Repo)
    repo_config = Keyword.put(repo_config, :adapter, Ecto.Adapters.Postgres)

    IO.inspect repo_config

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
    IO.puts "==> Set priv_dir to "  <> priv_dir
    migrations_dir = Path.join([priv_dir, "repo", "migrations"])
    IO.puts "==> Set migrations_dir to " <> migrations_dir
    opts = [all: true]
    IO.puts "==> Set opts to all"
    # pool = ClecodesEx.Repo.config[:pool]

    # if function_exported?(pool, :unboxed_run, 2) do
    #   pool.unboxed_run(ClecodesEx.Repo, fn -> Ecto.Migrator.run(ClecodesEx.Repo, migrations_dir, :up, opts) end)
    # else
    #   Ecto.Migrator.run(ClecodesEx.Repo, migrations_dir, :up, opts)
    # end

    # Shut down
    :init.stop()
  end
end
