defmodule ESx.API.Utils do

  def escape(string) when string == "*", do: string
  def escape(string) do
    "#{:edoc_lib.escape_uri '#{string}'}"
  end

  # TODO: More
  def listify(nil),do: nil
  def listify(list) when is_bitstring(list), do: list
  def listify(list) when is_list(list) do
    list
    |> Enum.join(",")
  end

  # TODO: More
  def pathify(segments) when is_bitstring(segments), do: segments
  def pathify(segments) when is_list(segments) do
    segments
    |> Enum.filter(& &1)
    |> Enum.join("/")
  end

  def bulkify(payload) do
    p = payload
    f = List.first(p)
    ops = ~w(index create delete update)

    cond do
      is_list(p) and is_map(f) && "#{List.first(Map.keys(f))}" in ops && (Map.values(f)[:data] || Map.values(f)["data"]) ->
        nil
      true ->
        nil
    end
  end

end
