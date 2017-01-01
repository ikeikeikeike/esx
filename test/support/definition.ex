defmodule ESx.Test.Support.Definition do

  defmodule Model do
    @moduledoc false

    use ESx.Model.Base, app: :esx
  end

  defmodule Schema do
    @moduledoc false

    use ESx.Schema

    defstruct [:id, :title]

    index_name    "test_schema_index"
    document_type "test_schema_type"

    mapping _ttl: [enabled: true, default: "180d"], _all: [enabled: false] do
      indexes :title, type: "string",
        analyzer: "ngram_analyzer",
        search_analyzer: "ngram_analyzer"
      indexes :content, type: "string",
        analyzer: "ngram_analyzer",
        search_analyzer: "ngram_analyzer"
    end

    settings number_of_replicas: "5", number_of_shards: "10" do
      analysis do
        analyzer :ngram_analyzer,
          tokenizer: "ngram_tokenizer",
          char_filter: ["html_strip", "kuromoji_neologd_iteration_mark"],
          filter: ["lowercase", "kuromoji_neologd_stemmer", "cjk_width"]
        tokenizer :ngram_tokenizer,
          type: "nGram", min_gram: "2", max_gram: "3",
          token_chars: ["letter", "digit"]
        filter "edge_ngram",
          type: "edgeNGram", min_gram: 1, max_gram: 15
      end
    end

    def as_indexed_json(%{} = schema, opts) do
      super(schema, opts)
    end
  end

  defmodule NonameSchema do
    @moduledoc false
    use ESx.Schema
  end

  defmodule NoDSLSchema do
    @moduledoc false

    use ESx.Schema

    defstruct [:id, :title]

    index_name    "test_no_dsl_schema_index"
    document_type "test_no_dsl_schema_type"

    mapping [
      _ttl: [
        enabled: true,
        default: "180d",
      ],
      _all: [
        enabled: false,
      ],
      properties: [
        title: [
          type: "string",
          analyzer: "ngram_analyzer",
          search_analyzer: "ngram_analyzer",
        ],
        content: [
          type: "string",
          analyzer: "ngram_analyzer",
          search_analyzer: "ngram_analyzer",
        ]
      ]
    ]

    settings [
      number_of_replicas: "5",
      number_of_shards: "10",
      analysis: [
        tokenizer: [
          ngram_tokenizer: [
            type: "nGram",
            token_chars: [
              "letter",
              "digit"
            ],
            min_gram: "2",
            max_gram: "3"
          ]
        ],
        analyzer: [
          ngram_analyzer: [
            tokenizer: "ngram_tokenizer",
            filter: [
              "lowercase",
              "kuromoji_stemmer",
              "cjk_width"
            ],
            char_filter: [
              "html_strip",
              "kuromoji_iteration_mark"
            ]
          ]
        ],
        filter: [
          edge_ngram: [
            type: "edgeNGram",
            min_gram: 1, max_gram: 15
          ]
        ]
      ]
    ]
  end

end
