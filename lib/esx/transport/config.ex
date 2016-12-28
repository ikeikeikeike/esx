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

      cfg = Application.get_env(:esx, ESx.Model)
      cfg = Funcs.build_url!(cfg) ++ [trace: cfg[:trace]]

      @defconfig cfg
      def defconfig, do: @defconfig
    end
  end
end
