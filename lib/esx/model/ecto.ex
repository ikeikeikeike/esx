# Temporary fix
if Code.ensure_loaded?(Ecto) do
  defmodule ESx.Model.Ecto do

    defmacro __using__(_) do
      quote do
        require Ecto.Query

        # https://github.com/DavidAntaramian/tributary/
        defp stream(queryable, opts \\ []) do

          chunk_size  = Keyword.get(opts, :chunk_size, 5_000)
          key_name    = Keyword.get(opts, :key_name, :id)
          order_name  = Keyword.get(opts, :order_name, :id)
          initial_key = Keyword.get(opts, :initial_key, 0)

          Stream.resource(
            fn -> {queryable, initial_key} end,
            fn {queryable, last_seen_key} ->
              results =
                queryable
                |> Ecto.Query.where([r], field(r, ^key_name) > ^last_seen_key)
                |> Ecto.Query.limit(^chunk_size)
                |> Ecto.Query.order_by(^order_name)
                |> repo.all # (Enum.into(opts, []))

              case List.last(results) do
                %{^key_name => last_key} ->
                  {results, {queryable, last_key}}
                nil ->
                  {:halt, {queryable, last_seen_key}}
              end
            end,
            fn _ -> [] end
          )
        end

        defp transform(schema, opts) do
          mod  = ESx.Funcs.to_mod schema
          %{index: %{_id: schema.id, data: mod.as_indexed_json(schema, opts)}}
        end

      end
    end
  end
else
  defmodule ESx.Model.Ecto do
    defmacro __using__(_) do
      quote do
        defp stream(_query, _opts \\ []) do
          raise "could not load `Ecto` module. please install it."
        end
        defp transform(_schema, _opts) do
          raise "could not load `Ecto` module. please install it."
        end
      end
    end
  end
end
