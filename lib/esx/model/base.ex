defmodule ESx.Model.Base do
  @doc false
  defmacro __using__(opts) do
    opts = Keyword.update opts, :app, :esx, & &1

    quote bind_quoted: [opts: opts] do
      {app, transport, config} = ESx.Model.Config.resource(__MODULE__, opts)
      @app       app
      @config    config
      @transport transport

      def repo do
        @config[:repo]
      end
      def config do
        @config
      end
      def transport do
        @transport
      end

      alias ESx.{API, Funcs}
      alias ESx.API.Indices

      def search(schema, query_or_payload, opts \\ %{}) do
        mod   = Funcs.to_mod schema
        index = opts[:index] || mod.__es_index_name__
        type  = opts[:type]  || mod.__es_document_type__
        body  = query_or_payload

        rsp =
          cond do
            is_map(body) ->
              API.search @transport, %{index: index, type: type, body: body}

            is_binary(body) && body =~ ~r/^\s*{/ ->
              API.search @transport, %{index: index, type: type, body: body}

            true ->
              API.search @transport, %{index: index, type: type, q: body}
          end

        ESx.Model.Response.parse __MODULE__, rsp
      end

      def create_index(schema, opts \\ %{}) do
        mod   = Funcs.to_mod schema
        index = opts[:index] || mod.__es_index_name__
        type  = opts[:type]  || mod.__es_document_type__

        properties = mod.__es_mapping__(:to_map)
        analysis =
          if function_exported?(mod, :__es_analysis__, 1) do
             %{settings: mod.__es_analysis__(:to_map)}
          else
            %{}
          end

        body = Map.merge %{mappings: Map.new([{type, properties}])}, analysis
        Indices.create @transport, %{index: index, body: body}
      end

      def index_exists?(schema, opts \\ %{}) do
        mod   = Funcs.to_mod schema
        index = opts[:index] || mod.__es_index_name__

        Indices.exists? @transport, %{index: index}
      end

      def delete_index(schema, opts \\ %{}) do
        mod   = Funcs.to_mod schema
        index = opts[:index] || mod.__es_index_name__

        Indices.delete @transport, %{index: index}
      end

    end
  end
end
