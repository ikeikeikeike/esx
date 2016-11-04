defmodule Tracer do
  defmacro trace(expression_ast) do
    string_representation = Macro.to_string(expression_ast)

    quote do
      result = unquote(expression_ast)
      Tracer.print(unquote(string_representation), result)
      result
    end
  end

  def print(string_representation, result) do
    IO.puts "Result of #{string_representation}: #{inspect result}"
  end
end
