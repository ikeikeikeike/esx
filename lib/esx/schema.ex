defmodule ESx.Schema do
  @doc false
  defmacro __using__(_opts) do
    quote do
      use ESx.Schema.{Mapping, Analysis, Naming}

      def as_indexed_json(%{} = schema, opts \\ %{}) do
        Poison.encode! schema
      end
    end
  end
end
