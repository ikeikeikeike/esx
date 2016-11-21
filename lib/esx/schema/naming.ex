defmodule ESx.Schema.Naming do
  alias ESx.Schema.Naming, as: Naming
  alias ESx.Funcs

  @doc false
  defmacro __using__(_) do
    quote do
      import Naming, only: [index_name: 1, document_type: 1]

      Module.register_attribute(__MODULE__, :es_document_type, accumulate: false)
      Module.register_attribute(__MODULE__, :es_index_name, accumulate: false)
    end
  end

  defmacro index_name(name) do
    quote do
      Module.put_attribute(__MODULE__, :es_index_name, "#{unquote(name)}")

      def __es_naming__(:index_name) do
        @es_index_name || Funcs.to_index_name(__MODULE__)
      end
    end
  end
  defmacro document_type(name) do
    quote do
      Module.put_attribute(__MODULE__, :es_document_type, "#{unquote(name)}")

      def __es_naming__(:document_type) do
        @es_document_type || Funcs.to_document_type(__MODULE__)
      end
    end
  end

end
