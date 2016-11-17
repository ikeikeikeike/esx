defmodule ESx.Schema do
  @doc false
  defmacro __using__(_opts) do
    quote do
      use ESx.Schema.{Mapping, Analysis, Naming}
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def as_indexed_json(%{} = schema, opts \\ %{}) do
        Poison.encode! schema
      end
    end
  end
end
