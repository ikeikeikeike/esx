defmodule ESx.Transport.Config do
  @doc false
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    cfg = Application.get_env(:esx, ESx.Model)
    cfg = ESx.Funcs.build_url!(cfg) ++ [trace: cfg[:trace], options: cfg[:options]]

    quote do
      def defconfig, do: unquote(cfg)
    end
  end
end
