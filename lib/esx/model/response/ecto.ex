defmodule ESx.Model.Response.Ecto do
  defmacro __before_compile__(_env) do
    quote do
      if Code.ensure_loaded?(Ecto) do

        def records(schema) do
          records schema, schema.__schema__
        end

        def records(schema, queryable) do
          require Ecto.Query  # XXX: Temporary fix

          ids = Enum.map schema.hits, & &1["_id"]
          elems = schema.__model__.repo.all(Ecto.Query.from q in queryable, where: q.id in ^ids)

          elems =
            Enum.map schema.hits, fn hit ->
              [elm] = Enum.filter elems, & "#{hit["_id"]}" == "#{&1.id}"
               elm
            end

          %{schema | records: elems}
        end

      else
        def records(_st, _queryable) do
          raise "could not load `Ecto` module. please install it."
        end
      end
    end
  end
end
