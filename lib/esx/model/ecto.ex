defmodule ESx.Model.Ecto do
  defmacro __before_compile__(_env) do
    quote do
      if Code.ensure_loaded?(Ecto) do
        def records(st, queryable) do
          require Ecto.Query

          repo = st.__model__.repo

          ids = Enum.map st.hits, & &1["_id"]
          records = repo.all(Ecto.Query.from q in queryable, where: q.id in ^ids)

          Enum.map st.hits, fn hit ->
            [record] = Enum.filter records, & "#{hit["_id"]}" == "#{&1.id}"
            List.delete records, record
            record
          end
        end
      else
        def records(_st, _queryable) do
          raise "could not load `Ecto` module. please install it."
        end
      end
    end
  end
end
