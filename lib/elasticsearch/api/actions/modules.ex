defmodule Elasticsearch.API.Actions.Modules do
  defmacro __using__(_opt) do
    infos = [
      Elasticsearch.API.Actions.Index.module_info,
      Elasticsearch.API.Actions.Info.module_info,
      Elasticsearch.API.Actions.Ping.module_info,
      Elasticsearch.API.Actions.Search.module_info,
    ]
    quote do
      Module.register_attribute __MODULE__, :routes, accumulate: true,
                                                     persist: false
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)

      Enum.map unquote(infos), fn info ->
        mod = info[:module]
        funcs = info[:module].__info__(:functions)

        @routes {funcs, mod}
      end
    end
  end

  defmacro delegate3(tuplelist, to: mod) when is_list(tuplelist) do
    Enum.map tuplelist, fn {fname, arity} ->
      args = Enum.map 1..arity, & :"arg#{&1}"
      quote do
        Tracer.print(unquote(fname), unquote(args))
        def unquote(fname)(unquote_splicing(args)) do
          apply unquote(mod), unquote(fname), unquote(args)
        end
      end
    end
  end

  defmacro __before_compile__(env) do
    routes = Module.get_attribute(env.module, :routes)

    for route <- routes do
      {info, mod} = route
      quote do
        delegate3 unquote(info), to: unquote(mod)

        def routes, do: unquote(routes)
      end
    end

  end

end
