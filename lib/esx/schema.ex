defmodule ESx.Schema do
  @doc false
  defmacro __using__(_opts) do
    quote do
      use ESx.Schema.{Mapping, Analysis, Naming}
    end
  end
end
