defmodule ESx.Funcs do

  def to_mod(%{__struct__: mod}), do: mod
  def to_mod(mod), do: mod

  def to_index_name(mod) do
    to_mod(mod)
    |> to_string
    |> String.split(".")
    |> Enum.take(-2)
    |> Enum.join("-")
    |> String.downcase
  end

  def to_document_type(mod), do: to_index_name mod

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
