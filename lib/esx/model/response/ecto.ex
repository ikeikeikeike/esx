# Temporary fix
if Code.ensure_loaded?(Ecto) do
  defmodule ESx.Model.Response.Ecto do
    defmacro __using__(_) do
      quote do
        require Ecto.Query

        def records(%{__schema__: schema} = search) do
          records(search, schema)
        end

        def records(%{__schema__: schema, __model__: model} = search, queryable) do
          rsp = ESx.Model.Search.execute(search)
          response = ESx.Model.Response.parse(model, schema, rsp)

          ids = Enum.map(response.hits, & &1["_id"])
          records = model.repo.all(Ecto.Query.from(q in queryable, where: q.id in ^ids))

          records =
            Enum.map(response.hits, fn hit ->
              [elm] = Enum.filter(records, &("#{hit["_id"]}" == "#{&1.id}"))
              elm
            end)

          %{response | records: records}
        end
      end
    end
  end
else
  defmodule ESx.Model.Response.Ecto do
    defmacro __using__(_) do
      quote do
        def records(%{__model__: model} = _search) do
          raise "could not load `Ecto` module. please install it, then sets `#{model}` into Mix.Config "
        end

        def records(%{__model__: model} = _search, _queryable) do
          raise "could not load `Ecto` module. please install it, then sets `#{model}` into Mix.Config "
        end
      end
    end
  end
end
