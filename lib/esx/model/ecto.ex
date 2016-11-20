defmodule ESx.Model.Ecto do
  defmacro __before_compile__(_env) do
    quote do
      if Code.ensure_loaded?(Ecto) do

        # https://github.com/DavidAntaramian/tributary/
        defp stream(queryable, opts \\ %{}) do
          require Ecto.Query  # XXX: Temporary fix

          chunk_size  = Map.get(opts, :chunk_size, 10000)
          key_name    = Map.get(opts, :key_name, :id)
          order_name  = Map.get(opts, :order_name, :id)
          initial_key = Map.get(opts, :initial_key, 0)

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

        defp transform(schema) do
          mod  = ESx.Funcs.to_mod schema
          %{index: %{ _id: schema.id, data: mod.as_indexed_json(schema)}}
        end

      else
        defp stream(_query, _opts) do
          raise "could not load `Ecto` module. please install it."
        end
        defp transform(_schema) do
          raise "could not load `Ecto` module. please install it."
        end
      end
    end
  end
end
