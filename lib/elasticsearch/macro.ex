defmodule Elasticsearch.Macro do
  defmacro delegate3(tuplelist, to: mod) when is_list(tuplelist) do
    Enum.map tuplelist, fn {fname, arity} ->
      args = Enum.map 1..arity, & :"arg#{&1}"
      quote do
       def unquote(fname)(unquote_splicing(args)) do
         apply unquote(mod), unquote(fname), unquote(args)
       end
      end
    end
  end
end
