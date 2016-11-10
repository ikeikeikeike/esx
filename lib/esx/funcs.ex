defmodule ESx.Funcs do

  def to_map(any) when is_map(any), do: to_map Enum.into(any, [])
  def to_map(any) when is_list(any) do
    Enum.reduce any, %{}, fn {key, value}, acc ->
      map =
        if Keyword.keyword?(value) do
          Map.new [{:"#{key}", to_map(value)}]
        else
          Map.new [{:"#{key}", value}]
        end

      Map.merge acc, map
    end
  end

end
