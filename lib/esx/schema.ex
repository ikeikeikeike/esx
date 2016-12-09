defmodule ESx.Schema do
  @doc false
  defmacro __using__(_opts) do
    quote do
      use ESx.Schema.{Mapping, Analysis, Naming}
      @before_compile unquote(__MODULE__)

      def as_indexed_json(schema, opts \\ %{})  # for compile warning
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def as_indexed_json(%{} = schema, opts) do
        types = ESx.Funcs.to_mod(schema).__es_mapping__(:types)
        Map.take schema, Keyword.keys(types)
      end

      defoverridable [as_indexed_json: 2]
    end
  end
end
