# ESx

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `esx` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:esx, github: "ikeikeikeike/esx"}]
    end
    ```

  2. Ensure `esx` is started before your application:

    ```elixir
    def application do
      [applications: [:esx]]
    end
    ```


```elixir
defmodule YourApp.Model do
  use ESx.Schema

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

ESx.Schema.create_index, st

ESx.Schema.search, st, query: %{}
```

```elixir
ts = ESx.Transport.transport trace: true

ESx.API.search ts, %{index: "your_app", body: %{query: %{}}}

ESx.API.Indices.delete ts, %{index: "your_app"}
```

### TODO

- Http Connection Pool
- Some of APIs
- Everything for me which uses own project.
