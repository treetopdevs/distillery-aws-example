use Mix.Config

# Application name
app = System.get_env("APPLICATION_NAME")
env = System.get_env("ENVIRONMENT_NAME")
region = System.get_env("AWS_REGION")
db_user = System.get_env("DATABASE_USER")
db_name = System.get_env("DATABASE_NAME")
db_host = System.get_env("DATABASE_HOST")

# Locate awscli
aws = System.find_executable("aws")

cond do
  is_nil(app) ->
    raise "APPLICATION_NAME is unset!"
  is_nil(env) ->
    raise "ENVIRONMENT_NAME is unset!"
  is_nil(aws) ->
    raise "Unable to find `aws` executable!"
  is_nil(db_user) ->
    raise "No DB User"
  is_nil(db_name) ->
    raise "No DB Name"
  is_nil(db_host) ->
    raise "No DB Host"
  :else ->
    :ok
end

# Pull database password from SSM
db_secret_name = "/#{app}/#{env}/database/password"
db_password =
  case System.cmd(aws, ["ssm", "get-parameter", "--region=#{region}", "--name=#{db_secret_name}", "--with-decryption"]) do
    {json, 0} ->
      %{"Parameter" => %{"Value" => password}} = Jason.decode!(json)
      password
    {output, status} ->
      raise "Unable to get database password, command exited with status #{status}:\n#{output}"
  end

config :distillery_example, ClecodesEx.Repo,
  show_sensitive_data_on_connection_error: true,
  username: db_user,
  password: db_password,
  database: db_name,
  hostname: db_host,
  pool_size: 15

# Set configuration for Phoenix endpoint
config :distillery_example, ClecodesExWeb.Endpoint,
  http: [port: 4000],
  url: [host: "localhost", port: 4000],
  root: ".",
  secret_key_base: "u1QXlca4XEZKb1o3HL/aUlznI1qstCNAQ6yme/lFbFIs0Iqiq/annZ+Ty8JyUCDc"

  config :libcluster,
  topologies: [
    clecodes: [
      strategy: ClusterEC2.Strategy.Tags,
      ec2_tagname: "Name",
      ec2_tagvalue: "#{app}-#{env}",
      app_prefix: "distillery_example"
    ]
  ]
