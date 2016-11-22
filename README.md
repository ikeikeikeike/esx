# ESx

A client for the Elasticsearch, written in Elixir which's still development status.

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
defmodule MyApp.ESx do
  use ESx.Model.Base, app: :my_app
end
```

And so that there's `MyApp.ESx` configuration for Mix.config below.

```elixir
config :my_app, MyApp.ESx,
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

## Definition for Analysis.

#### DSL
```elixir
defmodule MyApp.Blog do
  use ESx.Schema

  index_name    "blog"  # as required
  document_type "blog"  # as required

  mapping _all: [enabled: false], _ttl: [enabled: true, default: "180d"] do
    indexes :title, type: "string"
    indexes :content, type: "string"
    indexes :publish, type: "boolean"
  end

  settings number_of_shards: 10, number_of_replicas: 2 do
    analysis do
      filter :ja_posfilter,
        type: "kuromoji_neologd_part_of_speech",
        stoptags: ["助詞-格助詞-一般", "助詞-終助詞"]
      tokenizer :ja_tokenizer,
        type: "kuromoji_neologd_tokenizer"
      analyzer :default,
        type: "custom", tokenizer: "ja_tokenizer",
        filter: ["kuromoji_neologd_baseform", "ja_posfilter", "cjk_width"]
    end
  end

end

```
#### Setting by keywords lists

```elixir
defmodule Something.Schema do
  use ESx.Schema

  mapping [
    _ttl: [
      enabled: true,
      default: "180d"
    ],
    _all: [
      enabled: false
    ],
    properties: [
      title: [
        type: "string",
        analyzer: "ja_analyzer"
      ],
      publish: [
        type: "boolean"
      ],
      content: [
        type: "string",
        analyzer: "ja_analyzer"
      ]
    ]
  ]

  settings [
    number_of_shards:   1,
    number_of_replicas: 0,
    analysis: [
      analyzer: [
        ja_analyzer: [
          type:      "custom",
          tokenizer: "kuromoji_neologd_tokenizer",
          filter:    ["kuromoji_neologd_baseform", "cjk_width"],
        ]
      ]
    ]
  ]

end
```

## Definition for updating record via such as Model.

```elixir
defmodule MyApp.Blog do
  use ESx.Schema

  defstruct [:id, :title, :content, :publish]

  mapping do
    indexes :title, type: "string"
    indexes :content, type: "string"
    indexes :publish, type: "boolean"
  end
end
```

#### With Ecto's Model

```elixir

defmodule MyApp.Blog do
  use MyApp.Web, :model
  use ESx.Schema

  schema "blogs" do
    field :title, :string
    field :content, :string
    field :publish, :boolean

    timestamps
  end

  mapping do
    indexes :title, type: "string"
    indexes :content, type: "string"
    indexes :publish, type: "boolean"
  end
```

###### Indexing Data

The data's elements which sends to Elasticsearch is able to customize that will make it, this way is the same as Ecto.

```elixir
defmodule MyApp.Blog do
  @derive {Poison.Encoder, only: [:title, :publish]}
  schema "blogs" do
    field :title, :string
    field :content, :string
    field :publish, :boolean

    timestamps
  end
end
```

When Ecto's Schema and ESx's mapping have defferent fields or for customization more, defining function `as_indexed_json` will make it in order to send relational data to Elasticsearch, too. Commonly it called via `ESx.Model.index_document`, `ESx.Model.update_document`.

```elixir
defmodule MyApp.Blog do
  def as_indexed_json(struct, opts) do
    ...
    ...

    Map.drop some_of_custmized_data, [:id]
  end
end
```

By default will send all of defined mapping's fields to Elasticsearch.


## Usage

### Indexing

```elixir
MyApp.ESx.create_index, MyApp.Blog
ESx.Model.index_exists?, MyApp.Blog
MyApp.ESx.delete_index, MyApp.Blog
ESx.Model.refresh_index, MyApp.Blog
```

### Document

```elixir
ESx.Model.import, MyApp.Blog
MyApp.ESx.index_document, %MyApp.Blog{id: 1, title: "egg"}
ESx.Model.delete_document, %MyApp.Blog{id: 1, title: "ham"}
```

### Search & Response

```elixir
ESx.Model.search, MyApp.Blog, %{query: %{match: %{title: "foo"}}}
```

```elixir
response =
  MyApp.Blog
  |> ESx.Model.search(%{query: %{match: %{title: "foo"}}})
  |> ESx.Model.results

IO.inspect Enum.map(response, fn r ->
  r["_source"]["title"]
end)
# ["foo", "egg", "some"]
```

##### With Phoenix's Ecto

```elixir
response =
  MyApp.Blog
  |> ESx.Model.search(%{query: %{match: %{title: "foo"}}})
  |> ESx.Model.records

IO.inspect Enum.each(response, fn r ->
  r.title
end)
# ["foo", "egg", "some"]
```

##### Pagination

[github.com/ikeikeikeike/scrivener_esx](https://github.com/ikeikeikeike/scrivener_esx)

```elixir
page =
  MyApp.Blog
  |> MyApp.ESx.search(%{query: %{match: %{title: "foo"}}})
  |> MyApp.ESx.paginate(page: 2, page_size: 5)
```


## Low-level APIs

There're Low-level APIs in `ESx.API` and `ESx.API.Indices`.

```elixir
ts = ESx.Transport.transport trace: true  # or: ts = ESx.Model.transport

ESx.API.search ts, %{index: "your_app", body: %{query: %{}}}

ESx.API.Indices.delete ts, %{index: "your_app"}
```


### TODO

- Multiple configuration for transport
- Some of APIs
- Everything for me which uses own project.
- Aggregations, Suggestions
- Refactoring
- Unittest
