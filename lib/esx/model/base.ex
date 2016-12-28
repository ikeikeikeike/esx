defmodule ESx.Model.Base do
  @doc false
  defmacro __using__(opts) do
    opts = Keyword.update opts, :app, :esx, & &1

    quote bind_quoted: [opts: opts] do
      {app, config} = ESx.Model.Config.resource(__MODULE__, opts)
      @app       app
      @config    config

      def repo do
        @config[:repo]
      end
      def config do
        @config
      end
      def transport do
        ESx.Transport.transport config
      end

      use ESx.Model.Ecto

      alias ESx.{Funcs, API, API.Indices}

      def search(queryable, query_or_payload, opts \\ %{}) do
        mod   = Funcs.to_mod queryable
        index = opts[:index] || mod.__es_naming__(:index_name)
        type  = opts[:type]  || mod.__es_naming__(:document_type)
        body  = query_or_payload

        args =
          cond do
            is_map(body) ->
              %{index: index, type: type, body: body}

            is_binary(body) && body =~ ~r/^\s*{/ ->
              %{index: index, type: type, body: body}

            true ->
              %{index: index, type: type, q: body}
          end

        ESx.Model.Search.wrap __MODULE__, queryable, args
      end

      def create_index(schema, opts \\ %{}) do
        mod   = Funcs.to_mod schema
        index = opts[:index] || mod.__es_naming__(:index_name)
        type  = opts[:type]  || mod.__es_naming__(:document_type)

        properties = mod.__es_mapping__(:to_map)
        analysis =
          if function_exported?(mod, :__es_analysis__, 1) do
             %{settings: mod.__es_analysis__(:to_map)}
          else
            %{}
          end

        body = Map.merge %{mappings: Map.new([{type, properties}])}, analysis
        Indices.create transport, %{index: index, body: body}
      end

      def index_exists?(schema, opts \\ %{}) do
        mod   = Funcs.to_mod schema
        index = opts[:index] || mod.__es_naming__(:index_name)

        Indices.exists? transport, %{index: index}
      end

      def delete_index(schema, opts \\ %{}) do
        mod   = Funcs.to_mod schema
        index = opts[:index] || mod.__es_naming__(:index_name)

        Indices.delete transport, %{index: index}
      end

      def refresh_index(schema, opts \\ %{}) do
        mod   = Funcs.to_mod schema
        index = opts[:index] || mod.__es_naming__(:index_name)

        Indices.refresh transport, %{index: index}
      end

      def import(schema, opts \\ %{}) do
        mod  = Funcs.to_mod schema

        {refresh, opts} = Map.pop opts, :refresh, false
        {index, opts}   = Map.pop opts, :index, mod.__es_naming__(:index_name)
        {type, opts}    = Map.pop opts, :type, mod.__es_naming__(:document_type)

        results =
          stream(schema, opts)
          |> Stream.chunk(50000, 50000, [])
          |> Stream.map(fn chunk ->
            body = Enum.map chunk, &transform/1
            args = %{
              index: index,
              type:  type,
              body:  body
            }

            API.bulk transport, args
          end)
          |> Stream.filter(fn
            {:ok, %{"errors" => false}} -> false
            _ -> true
          end)
          |> Enum.to_list

        {results, (if refresh, do: refresh_index(schema))}
      end

      # TODO: __changed_attributes, update_document

      def index_document(%{} = schema, opts \\ %{}) do
        mod  = Funcs.to_mod schema
        args = Map.merge %{
            index: mod.__es_naming__(:index_name),
            type:  mod.__es_naming__(:document_type),
            id:    schema.id,
            body:  mod.as_indexed_json(schema, opts),
        }, opts

        API.index transport, args
      end

      def delete_document(%{} = schema, opts \\ %{}) do
        mod  = Funcs.to_mod schema
        args = Map.merge %{
            index: mod.__es_naming__(:index_name),
            type:  mod.__es_naming__(:document_type),
            id:    schema.id,
        }, opts

        API.delete transport, args
      end

      defdelegate records(search, queryable), to: ESx.Model.Response, as: :records

      defdelegate records(search), to: ESx.Model.Response, as: :records

      defdelegate results(search), to: ESx.Model.Response, as: :results
    end
  end
end
