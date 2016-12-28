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

{:ok, files} = File.ls("./test/support")

Enum.each files, fn(file) ->
  Code.require_file "support/#{file}", __DIR__
end
