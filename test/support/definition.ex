defmodule ESX.Test.Support.Definition do

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

    mapping do
      indexes :title, type: "string",
        analyzer: "ngram_analyzer",
        search_analyzer: "ngram_analyzer"
      indexes :content, type: "string",
        analyzer: "ngram_analyzer",
        search_analyzer: "ngram_analyzer"
    end

    settings do
      analysis do
        analyzer :ngram_analyzer,
          tokenizer: "ngram_tokenizer",
          char_filter: ["html_strip", "kuromoji_neologd_iteration_mark"],
          filter: ["lowercase", "kuromoji_neologd_stemmer", "cjk_width"]
        tokenizer :ngram_tokenizer,
          type: "nGram", min_gram: "2", max_gram: "3",
          token_chars: ["letter", "digit"]
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


end
