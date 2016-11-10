# Elasticsearch

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `elasticsearch` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:elasticsearch, "~> 0.1.0"}]
    end
    ```

  2. Ensure `elasticsearch` is started before your application:

    ```elixir
    def application do
      [applications: [:elasticsearch]]
    end
    ```


```elixir
defmodule YourApp.Model do
  use Elasticsearch.Schema

  mapping do
    indexes "field1", type: "string"
    indexes "field2", type: "boolean"

    Enum.each 3..10, fn num ->
      indexes "field#{num}", type: "string"
    end
  end

  analysis do
    filter "ja_posfilter",
      type: "kuromoji_neologd_part_of_speech",
      stoptags: ["助詞-格助詞-一般", "助詞-終助詞"]
    filter "edge_ngram",
      type: "edgeNGram", min_gram: 1, max_gram: 15

    tokenizer "ja_tokenizer",
      type: "kuromoji_neologd_tokenizer"
    tokenizer "ngram_tokenizer",
      type: "nGram", min_gram: "2", max_gram: "3",
      token_chars: ["letter", "digit"]

    analyzer "default",
      type: "custom", tokenizer: "ja_tokenizer",
      filter: ["kuromoji_neologd_baseform", "ja_posfilter", "cjk_width"]
    analyzer "ja_analyzer",
      type: "custom", tokenizer: "ja_tokenizer",
      filter: ["kuromoji_neologd_baseform", "ja_posfilter", "cjk_width"]
    analyzer "ngram_analyzer",
      tokenizer: "ngram_tokenizer"

    Enum.each 0..2, fn num ->
      filter "ja_posfilter#{num}",
        type: "kuromoji_neologd_part_of_speech",
        stoptags: ["助詞-格助詞-一般", "助詞-終助詞"]
    end
    Enum.each 0..2, fn num ->
      tokenizer "ja_tokenizer#{num}",
        type: "kuromoji_neologd_tokenizer"
    end
    Enum.each 0..2, fn num ->
      analyzer "ngram_analyzer#{num}",
        tokenizer: "ngram_tokenizer"
    end
  end

end

st = %YourApp.Model{}

ES.Schema.create_index, st

ES.Schema.search, st, query: %{}
```

```elixir
ts = ES.Transport.transport trace: true

ES.API.search ts, %{index: "your_app", body: %{query: %{}}}

ES.API.Indices.delete ts, %{index: "your_app"}
```

### TODO

- Http Connection Pool
- Some of APIs
- Everything for me which uses own project.
