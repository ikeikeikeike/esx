defmodule ESx.Model.Base do
  @doc false
  defmacro __using__(opts) do
    opts = Keyword.update opts, :app, :esx, & &1

    quote bind_quoted: [opts: opts] do
      {app, transport, config} = ESx.Model.Config.resource(__MODULE__, opts)
      @app       app
      @config    config
      @transport transport

      def config do
        @config
      end
      def transport do
        @transport
      end

      alias ESx.Funcs
      alias ESx.API.Indices.Actions

      def create_index(model, opts \\ []) do
        mod = Funcs.to_mod model
        index = Keyword.get opts, :index, mod.__es_index_name__

        properties = mod.__es_mapping__(:to_map)
        analysis =
          if function_exported?(mod, :__es_analysis__, 1) do
             %{settings: mod.__es_analysis__(:to_map)}
          else
            %{}
          end

        body = Map.merge %{mappings: %{something: properties}}, analysis
        Actions.create @transport, %{index: index, body: body}
      end

      def delete_index(model, opts \\ []) do
        mod = Funcs.to_mod model
        index = Keyword.get opts, :index, mod.__es_index_name__

        Actions.delete @transport, %{index: index}
      end

    end
  end
end
