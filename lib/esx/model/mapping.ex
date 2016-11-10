defmodule ESx.Model.Mapping do
  alias ESx.Model.Mapping, as: Mapping
  alias ESx.Funcs

  @doc false
  defmacro __using__(_) do
    quote do
      import Mapping, only: [mapping: 1]

      Module.register_attribute(__MODULE__, :es_mappings, accumulate: true)
    end
  end

  defmacro mapping([do: block]) do
    es_mapping(__MODULE__, block)
  end

  @doc false
  def es_mapping(_mod, block) do
    quote do
      # mod = unquote(mod)

      try do
        import Mapping
        unquote(block)
      after
        :ok
      end

      mappings = @es_mappings |> Enum.reverse

      Module.eval_quoted __ENV__, [
        Mapping.__es_mappings__(mappings),
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
  def __es_mappings__(mappings) do
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
      def __es_mapping__(:to_map), do: %{properties: Funcs.to_map(unquote(types))}
      def __es_mapping__(:as_json), do: __es_mapping__ :to_map
      def __es_mapping__(:types), do: unquote(types)
      unquote(quoted)
      def __es_mapping__(:type, _), do: nil
    end
  end

end
