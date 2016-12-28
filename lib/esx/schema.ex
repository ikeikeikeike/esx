defmodule ESx.Schema do
  @doc false
  defmacro __using__(_opts) do
    quote do
      use ESx.Schema.{Mapping, Analysis, Naming}

      def as_indexed_json(%{} = schema, opts) do
        types = ESx.Funcs.to_mod(schema).__es_mapping__(:types)
        Map.take schema, Keyword.keys(types)
      end

      defoverridable [as_indexed_json: 2]
    end
  end
end
