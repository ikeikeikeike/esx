defmodule ESx.Schema.Analysis do
  alias ESx.Schema.Analysis, as: Analysis
  alias ESx.Funcs

  @doc false
  defmacro __using__(_) do
    quote do
      import Analysis, only: [analysis: 1]

      Module.register_attribute(__MODULE__, :es_analyses, accumulate: true)
    end
  end

  defmacro analysis([do: block]) do
    es_analysis(__MODULE__, block)
  end

  @doc false
  def es_analysis(_mod, block) do
    quote do
      # mod = unquote(mod)

      try do
        import Analysis
        unquote(block)
      after
        :ok
      end

      analyses = @es_analyses |> Enum.reverse

      Module.eval_quoted __ENV__, [
        Analysis.__es_analyses__(analyses),
      ]
    end
  end

  defmacro tokenizer(name, opts) when is_list(opts) do
    quote do
      Analysis.__es_tokenizer__(__MODULE__, unquote(name), unquote(opts))
    end
  end
  defmacro analyzer(name, opts) when is_list(opts) do
    quote do
      Analysis.__es_analysers__(__MODULE__, unquote(name), unquote(opts))
    end
  end
  defmacro filter(name, opts) when is_list(opts) do
    quote do
      Analysis.__es_filters__(__MODULE__, unquote(name), unquote(opts))
    end
  end

  @doc false
  def __es_tokenizer__(mod, name, opts) do
    Module.put_attribute(mod, :es_analyses, {:tokenizer, :"#{name}", opts})
  end
  @doc false
  def __es_analysers__(mod, name, opts) do
    Module.put_attribute(mod, :es_analyses, {:analyzer, :"#{name}", opts})
  end
  @doc false
  def __es_filters__(mod, name, opts) do
    Module.put_attribute(mod, :es_analyses, {:filter, :"#{name}", opts})
  end

  @doc false
  def __es_analyses__(analyses) do
    types =
      Enum.reduce analyses, [], fn {type, name, opts}, acc ->
        m = Keyword.new([{name, opts}])
        Keyword.update(acc, type, m, & Keyword.merge(&1, m))
      end

    quoted =
      Enum.map(types, fn {type, map} ->
        quote do
          def __es_analysis__(:type, unquote(type)) do
            unquote(Macro.escape(map))
          end
          def __es_analysis__(:type, unquote("#{type}")) do
            unquote(Macro.escape(map))
          end
        end
      end)

    escaped = Macro.escape(types)

    quote do
      def __es_analysis__(:to_map), do: %{analysis: Funcs.to_map(unquote(escaped))}
      def __es_analysis__(:as_json), do: __es_analysis__ :to_map
      def __es_analysis__(:types), do: unquote(escaped)
      unquote(quoted)
      def __es_analysis__(:type, _), do: nil
    end
  end

end
