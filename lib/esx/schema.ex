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
        Map.drop schema, [:id]  # TODO: make sure to see original code
      end
    end
  end
end
