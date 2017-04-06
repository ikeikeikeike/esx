ExUnit.start()

host = String.to_char_list(System.get_env("ESX_TEST_HOST") || "localhost")
port = String.to_integer(System.get_env("ESX_TEST_PORT") || "9200")

case :gen_tcp.connect(host, port, []) do
  {:ok, socket} ->
    :gen_tcp.close(socket)
  {:error, reason} ->
    Mix.raise "Cannot connect to Elasticsearch" <>
              "(http://#{host}:#{port}): #{:inet.format_error(reason)}"
end

defmodule ESx.Test.TestCase do
  use ExUnit.CaseTemplate

  setup do
    # Explicitly get a connection before each test
    # By default the test is wrapped in a transaction
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ESx.Test.Support.Repo)

    # The :shared mode allows a process to share
    # its connection with any other process automatically
    Ecto.Adapters.SQL.Sandbox.mode(ESx.Test.Support.Repo, {:shared, self()})
  end
end

{:ok, _pid} = ESx.Test.Support.Repo.start_link
Ecto.Adapters.SQL.Sandbox.mode(ESx.Test.Support.Repo, {:shared, self()})
