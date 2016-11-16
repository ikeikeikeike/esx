defmodule ESx.Schema.Naming do
  alias ESx.Schema.Naming, as: Naming
  alias ESx.Funcs

  @doc false
  defmacro __using__(_) do
    quote do
      import Naming, only: [index_name: 1, document_type: 1]

      Module.register_attribute(__MODULE__, :es_document_type, accumulate: false)
      Module.register_attribute(__MODULE__, :es_index_name, accumulate: false)

      def __es_index_name__, do: @es_index_name || Funcs.to_index_name(__MODULE__)
      def __es_document_type__, do: @es_document_type || Funcs.to_document_type(__MODULE__)
    end
  end

  defmacro index_name(name) do
    quote do
      Mapping.__es_index_name__(__MODULE__, unquote(name))
    end
  end
  defmacro document_type(name) do
    quote do
      Mapping.__es_document_type__(__MODULE__, unquote(name))
    end
  end

  @doc false
  def __es_index_name__(mod, name, opts) do
    Module.put_attribute(mod, :es_index_name, :"#{name}")
  end
  @doc false
  def __es_document_type__(mod, name, opts) do
    Module.put_attribute(mod, :es_document_type, :"#{name}")
  end


end
