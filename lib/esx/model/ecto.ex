defmodule ESx.Model.Ecto do
  defmacro __before_compile__(_env) do
    quote do
      if Code.ensure_loaded?(Ecto) do

        def records(st) do
          records st, st.__schema__
        end

        def records(st, queryable) do
          require Ecto.Query  # XXX: Temporary fix

          ids = Enum.map st.hits, & &1["_id"]
          elems = st.__model__.repo.all(Ecto.Query.from q in queryable, where: q.id in ^ids)

          elems =
            Enum.map st.hits, fn hit ->
              [elm] = Enum.filter elems, & "#{hit["_id"]}" == "#{&1.id}"
              List.delete elems, elm
              elm
            end

          %{st | records: elems}
        end
      else
        def records(_st, _queryable) do
          raise "could not load `Ecto` module. please install it."
        end
      end
    end
  end
end
