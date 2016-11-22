# XXX: Temporary fix which this loader code.
defmodule ESx.Model.Response.Ecto do
  defmacro __before_compile__(_env) do
    quote do
      if Code.ensure_loaded?(Ecto) do

        def records(%{__schema__: schema} = search) do
          records search, schema
        end

        def records(%{__schema__: schema, __model__: model} = search, queryable) do
          require Ecto.Query  # XXX: Temporary fix

          rsp = ESx.Model.Search.execute search
          response = ESx.Model.Response.parse model, schema, rsp

          ids = Enum.map response.hits, & &1["_id"]
          records = model.repo.all(Ecto.Query.from q in queryable, where: q.id in ^ids)

          records =
            Enum.map response.hits, fn hit ->
              [elm] = Enum.filter records, & "#{hit["_id"]}" == "#{&1.id}"
               elm
            end

          %{response | records: records}
        end

      else
        def records(%{} = _search) do
          raise "could not load `Ecto` module. please install it."
        end
        def records(%{} = _search, _queryable) do
          raise "could not load `Ecto` module. please install it."
        end
      end
    end
  end
end
