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

## Configuration

```elixir
config :esx, ESx.Model,
  url: "http://example.com:9200"
```

#### Multiple configuration

###### This is configuration that if you've have multiple Elasticsearch's Endpoint which's another one.

First, that configuration is defined with `ESx.Model.Base` into your project. It's like Ecto's Repo.

```elixir
defmodule YourApp.AnotherModel do
  use ESx.Model.Base, app: :your_app
end
```

And so that there's `YourApp.AnotherModel` configuration for Mix.config below.

```elixir
config :your_app, YourApp.AnotherModel,
  scheme: "http",
  host: "example.com",
  port: 9200
```

#### Definition for all of configuration.

```elixir
config :esx, ESx.Model,
  protocol: "http",                        # or: scheme: "http"
  user: "yourname", password: "yourpass",  # or: userinfo: "yourname:yourpass"
  host: "localhost",
  port: 9200,
  path: "path-to-endpoint"
```

##  Definition for Analysis.


```elixir
defmodule YourApp do
  use ESx.Schema

  index_name "yourapp"

  document_type "doctype"

  mapping do
    indexes :title, type: "string"
    indexes :content, type: "string"
    indexes :publish, type: "boolean"
  end

  analysis do
    filter :ja_posfilter,
      type: "kuromoji_neologd_part_of_speech",
      stoptags: ["助詞-格助詞-一般", "助詞-終助詞"]
    filter "edge_ngram",
      type: "edgeNGram", min_gram: 1, max_gram: 15

    tokenizer :ja_tokenizer,
      type: "kuromoji_neologd_tokenizer"
    tokenizer :ngram_tokenizer,
      type: "nGram", min_gram: "2", max_gram: "3",
      token_chars: ["letter", "digit"]

    analyzer :default,
      type: "custom", tokenizer: "ja_tokenizer",
      filter: ["kuromoji_neologd_baseform", "ja_posfilter", "cjk_width"]
    analyzer :ja_analyzer,
      type: "custom", tokenizer: "ja_tokenizer",
      filter: ["kuromoji_neologd_baseform", "ja_posfilter", "cjk_width"]
    analyzer :ngram_analyzer,
      tokenizer: "ngram_tokenizer"
  end

end

```

## Usage

### Indexing

```elixir
ESx.Model.create_index, YourApp
```

### A search and response

```elixir
ESx.Model.search, YourApp, %{query: %{match: %{title: "foo"}}}
```

#### then a response

```elixir
%ESx.Model.Response{__model__: ESx.Model, __schema__: Extoon.Entry,
 aggregations: nil, hits: [], max_score: nil, records: nil,
 shards: %{"failed" => 0, "successful" => 5, "total" => 5}, suggestions: nil,
 timed_out: false, took: 3, total: 0}
```

##### With Phoenix's Ecto

```elixir
YourApp
|> ESx.Model.search(%{query: %{match: %{title: "foo"}}})
|> ESx.Model.Response.records
```

#### then a response

```elixir
%ESx.Model.Response{__model__: ESx.Model, __schema__: Extoon.Entry,
 aggregations: nil, hits: [], max_score: nil, records: [%YourApp{id: 1}, %YourApp{id: 2}, %YourApp{id: 3}],
 shards: %{"failed" => 0, "successful" => 5, "total" => 5}, suggestions: nil,
 timed_out: false, took: 3, total: 0}
```

## Low-level APIs


```elixir
ts = ESx.Transport.transport trace: true

ESx.API.search ts, %{index: "your_app", body: %{query: %{}}}

ESx.API.Indices.delete ts, %{index: "your_app"}
```

### TODO

- Http conn collection
- Consider to change Client proxy for multiple configuration
- Some of APIs
- Everything for me which uses own project.
