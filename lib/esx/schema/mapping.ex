defmodule ESx.Schema.Mapping do
  alias ESx.Schema.Mapping, as: Mapping
  alias ESx.Funcs

  @doc false
  defmacro __using__(_) do
    quote do
      import Mapping, only: [mapping: 1, mapping: 2]

      Module.register_attribute(__MODULE__, :es_mappings, accumulate: true)
    end
  end

  defmacro mapping(setting, [do: block]) do
    es_mapping(__MODULE__, setting, block)
  end

  defmacro mapping([do: block]) do
    es_mapping(__MODULE__, [], block)
  end

  # Setting dynamically
  defmacro mapping(keywords) when is_list(keywords) do
    {mappings, setting} = Keyword.pop keywords, :properties

    quote do
      Module.eval_quoted __ENV__, [
        Mapping.__es_mappings__(unquote(mappings), unquote(setting)),
      ]
    end
  end

  @doc false
  def es_mapping(_mod, setting, block) do
    quote do

      try do
        import Mapping
        unquote(block)
      after
        :ok
      end

      mappings = @es_mappings |> Enum.reverse

      Module.eval_quoted __ENV__, [
        Mapping.__es_mappings__(mappings, unquote(setting)),
      ]
    end
  end

  defmacro indexes(name, opts) when is_list(opts) do
    quote do
      Mapping.__es_indexes__(__MODULE__, unquote(name), unquote(opts))
    end
  end

  @doc false
  def __es_indexes__(mod, name, opts) do
    # opts = Keyword.update opts, :type, "string", & &1
    Module.put_attribute(mod, :es_mappings, {:"#{name}", opts})
  end

  @doc false
  def __es_mappings__(mappings, setting) do
    quoted =
      Enum.map(mappings, fn {name, opts} ->
        quote do
          def __es_mapping__(:type, unquote(name)) do
            unquote(Macro.escape(opts))
          end
          def __es_mapping__(:type, unquote("#{name}")) do
            unquote(Macro.escape(opts))
          end
        end
      end)

    types = Macro.escape(mappings)

    quote do
      def __es_mapping__(:to_map) do
        properties = %{properties: Funcs.to_map(unquote(types))}
        Map.merge Funcs.to_map(unquote(setting)), properties
      end
      def __es_mapping__(:as_json), do: __es_mapping__ :to_map
      def __es_mapping__(:types), do: unquote(types)
      unquote(quoted)
      def __es_mapping__(:type, _), do: nil

      def __es_mapping__(:settings), do: unquote(setting)
    end
  end

end
