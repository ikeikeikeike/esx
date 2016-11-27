defmodule ESx.Model.Search do
  alias ESx.{API, Funcs}

  defstruct [:__model__, :__schema__, args: %{}]

  @type t :: %__MODULE__{}

  def wrap(model, schema, args) do
    %__MODULE__{
      __model__: model,
      __schema__: schema,
      args: args,
    }
  end

  def execute(%{__model__: model, __schema__: schema, args: args}) do
    API.search model.transport, args
  end

end
