defmodule ESx.API.Utils do
  import ESx.Checks, only: [present?: 1]

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

  def bulkify(payload) when is_list(payload) do
    ops = ~w(index create delete update)

    any? = fn item ->
      values = List.first(Map.values(item))

      r = is_map(item)
      r = r and is_map(values)
      r = r and "#{List.first(Map.keys(item))}" in ops
      r and !!values[:data]
    end

    payload =
      cond do
        # Hashes with `:data`
        Enum.any? payload, any? ->
          payload =
            List.foldl(payload, [], fn item, acc ->
              {op, meta}   = Map.to_list(item) |> List.first
              {data, meta} = Map.pop meta, :data

              acc = acc ++ Map.new([{op, meta}])
              if data do
                acc ++ data
              else
                acc
              end
            end)
            |> Enum.map(& Poison.encode!/1)

          if present?(payload) do
            payload ++ [""]
          else
            payload
          end

        # Array of strings
        Enum.all? payload, & is_binary/1 ->
          payload ++ [""]

        # Header/Data pairs
        true ->
          payload = Enum.map payload, & Poison.encode!/1
          payload ++ [""]

      end

    Enum.join payload, "\n"
  end

end
