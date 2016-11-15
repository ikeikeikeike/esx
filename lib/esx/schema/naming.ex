defmodule ESx.Schema.Naming do
  alias ESx.Schema.Naming, as: Naming
  alias ESx.Funcs

  @doc false
  defmacro __using__(_) do
    quote do
      import Naming, only: [index_name: 1]

      Module.register_attribute(__MODULE__, :es_index_name, accumulate: false)

      def __es_index_name__, do: @es_index_name || Funcs.to_index_name(__MODULE__)
    end
  end

  defmacro index_name(name) do
    quote do
      Mapping.__es_index_name__(__MODULE__, unquote(name))
    end
  end

  @doc false
  def __es_index_name__(mod, name, opts) do
    Module.put_attribute(mod, :es_index_name, :"#{name}")
  end

end
