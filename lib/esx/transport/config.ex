defmodule ESx.Transport.Config do
  @doc false
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      alias ESx.Funcs

      def defconfig do
        cfg = Application.get_env(:esx, ESx.Model, [url: "http://127.0.0.1:9200"])
        Funcs.build_url!(cfg) ++ [trace: cfg[:trace]]
      end
    end
  end
end
