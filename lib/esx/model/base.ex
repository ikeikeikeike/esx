defmodule ESx.Model.Base do
  @doc false
  defmacro __using__(opts) do
    opts = Keyword.update opts, :otp_app, :esx, & &1

    quote bind_quoted: [opts: opts] do
      {otp_app, transport, config} = ESx.Model.Supervisor.parse_config(__MODULE__, opts)
      @otp_app   otp_app
      @config    config
      @transport transport

      def config do
        ESx.Model.Supervisor.config(__MODULE__, @otp_app, [])
      end
      def start_link(opts \\ []) do
        ESx.Model.Supervisor.start_link(__MODULE__, @otp_app, opts)
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
        Actions.create mod.__es_transport__, %{index: index, body: body}
      end

      def delete_index(model, opts \\ []) do
        mod = Funcs.to_mod model
        index = Keyword.get opts, :index, mod.__es_index_name__

        Actions.delete mod.__es_transport__, %{index: index}
      end

    end
  end
end
