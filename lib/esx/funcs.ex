defmodule ESx.Funcs do
  def to_mod(%{from: {_, mod}}), do: mod
  def to_mod(%{__struct__: mod}), do: mod
  def to_mod(mod), do: mod

  def to_index_name(mod) do
    to_mod(mod)
    |> to_string
    |> String.split(".")
    |> Enum.take(-2)
    |> Enum.join("-")
    |> String.downcase()
  end

  def to_document_type(mod), do: to_index_name(mod)

  def to_map(any) when is_map(any), do: to_map(Enum.into(any, []))

  def to_map(any) when is_list(any) do
    Enum.reduce(any, %{}, fn {key, value}, acc ->
      map =
        if Keyword.keyword?(value) do
          Map.new([{:"#{key}", to_map(value)}])
        else
          Map.new([{:"#{key}", value}])
        end

      Map.merge(acc, map)
    end)
  end

  def encid(mod, name) when is_list(mod) do
    encid(Enum.join(mod), name)
  end

  def encid(mod, name) do
    [mod, "_", name]
    |> Enum.join()
    |> Base.encode64()
    |> String.to_atom()
  end

  def decid(name) do
    "#{name}"
    |> Base.decode64!()
    |> String.split("_")
    |> List.last()
  end

  def build_url!([{url, _}| t]) when url != :url do
    build_url! t
  end

  def build_url!(url: url) when is_binary(url) do
    case URI.parse(url) do
      %URI{scheme: nil} -> raise ArgumentError, "Missing scheme in #{url}"
      %URI{host: nil} -> raise ArgumentError, "Missing host in #{url}"
      _ -> [url: url]
    end
  end

  def build_url!(url: {:system, env}) when is_binary(env) do
    build_url!(url: System.get_env(env))
  end

  def build_url!(url: _), do: raise(ArgumentError, "Missing url value")
  def build_url!([]), do: raise(ArgumentError, "Missing url value")

  def build_url!(cfg) when is_list(cfg) do
    u = URI.parse(Keyword.get(cfg, :url, ""))
    u = if cfg[:scheme], do: Map.put(u, :scheme, cfg[:scheme]), else: u
    u = if cfg[:host], do: Map.put(u, :host, cfg[:host]), else: u
    u = if cfg[:port], do: Map.put(u, :port, cfg[:port]), else: u
    u = if cfg[:user], do: Map.put(u, :userinfo, "#{cfg[:user]}:#{cfg[:password]}"), else: u

    build_url!(url: URI.to_string(u))
  end

  # for elixir 1.2
  # https://github.com/elixir-lang/elixir/blob/master/lib/elixir/lib/uri.ex#L467

  def merge(uri, rel)

  def merge(%URI{authority: nil}, _rel) do
    raise ArgumentError, "you must merge onto an absolute URI"
  end

  def merge(_base, %URI{scheme: rel_scheme} = rel) when rel_scheme != nil do
    rel
  end

  def merge(%URI{} = base, %URI{path: rel_path} = rel) when rel_path in ["", nil] do
    %{base | query: rel.query || base.query, fragment: rel.fragment}
  end

  def merge(%URI{} = base, %URI{} = rel) do
    new_path = merge_paths(base.path, rel.path)
    %{base | path: new_path, query: rel.query, fragment: rel.fragment}
  end

  def merge(base, rel) do
    merge(URI.parse(base), URI.parse(rel))
  end

  defp merge_paths(nil, rel_path),
    do: merge_paths("/", rel_path)

  defp merge_paths(_, "/" <> _ = rel_path),
    do: rel_path

  defp merge_paths(base_path, rel_path) do
    [_ | base_segments] = path_to_segments(base_path)

    path_to_segments(rel_path)
    |> Kernel.++(base_segments)
    |> remove_dot_segments([])
    |> Enum.join("/")
  end

  defp remove_dot_segments([], [head, ".." | acc]),
    do: remove_dot_segments([], [head | acc])

  defp remove_dot_segments([], acc),
    do: acc

  defp remove_dot_segments(["." | tail], acc),
    do: remove_dot_segments(tail, acc)

  defp remove_dot_segments([head | tail], ["..", ".." | _] = acc),
    do: remove_dot_segments(tail, [head | acc])

  defp remove_dot_segments(segments, [_, ".." | acc]),
    do: remove_dot_segments(segments, acc)

  defp remove_dot_segments([head | tail], acc),
    do: remove_dot_segments(tail, [head | acc])

  def path_to_segments(path) do
    [head | tail] = String.split(path, "/")
    reverse_and_discard_empty(tail, [head])
  end

  defp reverse_and_discard_empty([], acc),
    do: acc

  defp reverse_and_discard_empty([head], acc),
    do: [head | acc]

  defp reverse_and_discard_empty(["" | tail], acc),
    do: reverse_and_discard_empty(tail, acc)

  defp reverse_and_discard_empty([head | tail], acc),
    do: reverse_and_discard_empty(tail, [head | acc])
end
