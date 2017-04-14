defmodule ESx.Schema do
  @moduledoc """
  Define schema for elasticsaerch using Keyword lists and DSL.

  ## DSL Example

      defmodule MyApp.Blog do
        use ESx.Schema

        index_name    "blog"  # Optional
        document_type "blog"  # Optional

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

  ## Keyword lists Example

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


  """



  @doc false
  defmacro __using__(_opts) do
    quote do
      use ESx.Schema.{Mapping, Analysis, Naming}

      def as_indexed_json(%{} = schema, opts) do
        types = ESx.Funcs.to_mod(schema).__es_mapping__(:types)
        Map.take schema, Keyword.keys(types)
      end

      defoverridable [as_indexed_json: 2]
    end
  end
end
