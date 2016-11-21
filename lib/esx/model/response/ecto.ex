# XXX: Temporary fix which this loader code.
defmodule ESx.Model.Response.Ecto do
  defmacro __before_compile__(_env) do
    quote do
      if Code.ensure_loaded?(Ecto) do

        def records(%{__schema__: schema} = response) do
          records response, schema
        end

        def records(%{__model__: model} = response, queryable) do
          require Ecto.Query  # XXX: Temporary fix

          ids = Enum.map response.hits, & &1["_id"]
          elems = model.repo.all(Ecto.Query.from q in queryable, where: q.id in ^ids)

          elems =
            Enum.map response.hits, fn hit ->
              [elm] = Enum.filter elems, & "#{hit["_id"]}" == "#{&1.id}"
               elm
            end

          %{response | records: elems}
        end

      else
        def records(%{} = _response, _queryable) do
          raise "could not load `Ecto` module. please install it."
        end
      end
    end
  end
end
