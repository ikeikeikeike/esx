defmodule ESx.Model.Base do
  @moduledoc """
  Sets up esx that make it easy to configure and ecto adapters.

  ## Example

      # In your mix.esx file
      def application do
        [applications: [:esx]]
      end

      # In your config/config.exs file
      config :esx, ESx.Model,
        url: "http://example.com:9200",
        repo: MyApp.Repo  # defines Ecto for connecting database.

  ## Multiple configuration

  This is configuration that if you've have multiple Elasticsearch's Endpoint which's another one.
  First, that configuration is defined with `ESx.Model.Base` into your project. It's like Ecto's Repo.

  ## Example

      # In your lib/my_app/esx.ex file
      defmodule MyApp.ESx do
        use ESx.Model.Base, app: :my_app
      end

      # And so that there's `MyApp.ESx` configuration for Mix.config below.
      # In your config/config.exs file
      config :my_app, MyApp.ESx,
        scheme: "http",
        host: "example.com",
        port: 9200

  """

  @doc false
  defmacro __using__(opts) do
    opts = Keyword.update(opts, :app, :esx, & &1)

    quote bind_quoted: [opts: opts] do
      {app, config} = ESx.Model.Config.resource(__MODULE__, opts)
      @app app
      @config config

      def repo do
        @config[:repo]
      end

      def config do
        {_, config} = Keyword.pop(@config, :url)
        ESx.Funcs.build_url!(@config) ++ config
      end

      def transport do
        ESx.Transport.transport(config())
      end

      use ESx.Model.Ecto

      alias ESx.{Funcs, API, API.Indices}

      @doc """
      Search document from the data store matching the given query.

      ## Options

        * `:index` - document index name in es
        * `:type` - document type name in es

      ## Example

          # Search 'my document' from elasticsearch
          query = MyESx.search MyModel, %{query: %{match: %{title: "my document"}}}

          # Featch docuemnt from elasticsarch
          MyESx.results query

          # Featch docuemnt from elasticsarch as Record struct which contains [Ecto.Schema.t] records.
          MyESx.records query

      ## Example with ecto queryable

          # Set condition as issues ecto query.
          query = from q in MyModel,
            where: q.publish == true,
            preload: [:thumbs, :category, :maker]

          # Search 'my document' from elasticsearch
          query = MyESx.search query, %{query: %{match: %{title: "my document"}}}

          # Featch docuemnt from elasticsarch
          MyESx.results query

          # Featch docuemnt from elasticsarch as Record struct which contains [Ecto.Schema.t] records.
          MyESx.records query

      """
      def search(queryable, query_or_payload, opts \\ []) do
        mod = Funcs.to_mod(queryable)
        index = opts[:index] || mod.__es_naming__(:index_name)
        type = opts[:type] || mod.__es_naming__(:document_type)
        body = query_or_payload

        args =
          cond do
            is_map(body) ->
              %{index: index, type: type, body: body}

            is_binary(body) && body =~ ~r/^\s*{/ ->
              %{index: index, type: type, body: body}

            true ->
              %{index: index, type: type, q: body}
          end

        ESx.Model.Search.wrap(__MODULE__, queryable, args)
      end

      @doc """
      Create index with any options.

      ## Options

        * `:index` - document index name
        * `:type` - document type name

      ## Example

          # Make index with defined schema
          MyESx.create_index MyModel

          # Make index with defined schema
          MyESx.create_index MyModel, index: "any-index", type: "any-type"

      """
      def create_index(schema, opts \\ []) do
        mod = Funcs.to_mod(schema)
        index = opts[:index] || mod.__es_naming__(:index_name)
        type = opts[:type] || mod.__es_naming__(:document_type)

        properties = mod.__es_mapping__(:to_map)

        analysis =
          if function_exported?(mod, :__es_analysis__, 1) do
            %{settings: mod.__es_analysis__(:to_map)}
          else
            %{}
          end

        body = Map.merge(%{mappings: Map.new([{type, properties}])}, analysis)
        Indices.create(transport(), %{index: index, body: body})
      end

      def index_exists?(schema, opts \\ []) do
        mod = Funcs.to_mod(schema)
        index = opts[:index] || mod.__es_naming__(:index_name)

        Indices.exists?(transport(), %{index: index})
      end

      def delete_index(schema, opts \\ []) do
        mod = Funcs.to_mod(schema)
        index = opts[:index] || mod.__es_naming__(:index_name)

        Indices.delete(transport(), %{index: index})
      end

      def refresh_index(schema, opts \\ []) do
        mod = Funcs.to_mod(schema)
        index = opts[:index] || mod.__es_naming__(:index_name)

        Indices.refresh(transport(), %{index: index})
      end

      def reindex(schema, opts \\ []) do
        makeidx = &"#{&1}_#{:os.system_time()}"
        mod = Funcs.to_mod(schema)
        {index, opts} = Keyword.pop(opts, :index, mod.__es_naming__(:index_name))

        # create new index if cluster doesn't have that.
        case Indices.get_alias(transport(), index: index) do
          {:error, _} ->
            newidx = makeidx.(index)

            create_index(schema, index: newidx)

            Indices.put_alias(transport(), %{name: index, index: newidx})

          _ ->
            nil
        end

        newidx = makeidx.(index)

        oldidx =
          Indices.get_alias!(transport(), index: index)
          |> Map.keys()
          |> hd

        # Create index
        create_index(schema, index: newidx)

        # Import
        __MODULE__.import(schema, index: newidx)

        # Changes alias
        Indices.update_aliases(transport(), %{
          body: %{
            actions: [
              %{remove: %{index: oldidx, alias: index}},
              %{add: %{index: newidx, alias: index}}
            ]
          }
        })

        delete_index(schema, index: oldidx)
      end

      def import(schema, opts \\ []) do
        mod = Funcs.to_mod(schema)

        {refresh, opts} = Keyword.pop(opts, :refresh, false)
        {index, opts} = Keyword.pop(opts, :index, mod.__es_naming__(:index_name))
        {type, opts} = Keyword.pop(opts, :type, mod.__es_naming__(:document_type))

        chunk_size = Keyword.get(opts, :chunk_size, 5_000)

        results =
          stream(schema, Keyword.merge(opts, chunk_size: chunk_size))
          |> Stream.chunk_every(chunk_size, chunk_size, [])
          |> Stream.map(fn chunk ->
            body = Enum.map(chunk, &transform(&1, opts))

            args = %{
              index: index,
              type: type,
              body: body
            }

            API.bulk(transport(), args)
          end)
          |> Stream.filter(fn
            {:ok, %{"errors" => false}} -> false
            _ -> true
          end)
          |> Enum.to_list()

        {results, if(refresh, do: refresh_index(schema))}
      end

      # TODO: __changed_attributes, update_document

      # TODO: change keyword to opts
      def index_document(%{} = schema, opts \\ %{}) do
        mod = Funcs.to_mod(schema)

        args =
          Map.merge(
            %{
              index: mod.__es_naming__(:index_name),
              type: mod.__es_naming__(:document_type),
              id: schema.id,
              body: mod.as_indexed_json(schema, opts)
            },
            opts
          )

        API.index(transport(), args)
      end

      # TODO: change keyword to opts
      def delete_document(%{} = schema, opts \\ %{}) do
        mod = Funcs.to_mod(schema)

        args =
          Map.merge(
            %{
              index: mod.__es_naming__(:index_name),
              type: mod.__es_naming__(:document_type),
              id: schema.id
            },
            opts
          )

        API.delete(transport(), args)
      end

      defdelegate records(search, queryable), to: ESx.Model.Response, as: :records

      defdelegate records(search), to: ESx.Model.Response, as: :records

      defdelegate results(search), to: ESx.Model.Response, as: :results

      defoverridable config: 0
    end
  end
end
