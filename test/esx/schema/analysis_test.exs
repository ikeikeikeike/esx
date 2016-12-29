Code.require_file "../../../test_helper.exs", __ENV__.file

defmodule ESx.Model.AnalysisTest do
  use ExUnit.Case
  doctest ESx

  import ESX.Test.Support.Checks

  alias ESX.Test.Support.Definition.{Model, Schema, NonameSchema, NoDSLSchema}

  test "ok schema.analysis.__es_analysis__" do
    assert Schema.__es_analysis__(:to_map) ==  %{
      analysis: %{
        analyzer: %{
          ngram_analyzer: %{
            char_filter: ["html_strip", "kuromoji_neologd_iteration_mark"],
            filter: ["lowercase", "kuromoji_neologd_stemmer", "cjk_width"],
            tokenizer: "ngram_tokenizer"
          }
        },
        tokenizer: %{
          ngram_tokenizer: %{
            max_gram: "3", min_gram: "2",
            token_chars: ["letter", "digit"], type: "nGram"}
        },
        filter: %{
          edge_ngram: %{
            max_gram: 15, min_gram: 1,
            type: "edgeNGram"
          }
        }
      },
      number_of_replicas: "5",
      number_of_shards: "10"
    }

    assert Schema.__es_analysis__(:as_json) == %{
      analysis: %{
        analyzer: %{
          ngram_analyzer: %{
            char_filter: ["html_strip", "kuromoji_neologd_iteration_mark"],
            filter: ["lowercase", "kuromoji_neologd_stemmer", "cjk_width"],
            tokenizer: "ngram_tokenizer"
          }
        },
        tokenizer: %{
          ngram_tokenizer: %{
            max_gram: "3", min_gram: "2",
            token_chars: ["letter", "digit"], type: "nGram"}
        },
        filter: %{
          edge_ngram: %{
            max_gram: 15, min_gram: 1,
            type: "edgeNGram"
          }
        }
      },
      number_of_replicas: "5",
      number_of_shards: "10"
    }

    assert Schema.__es_analysis__(:types) == [
      analyzer: [
        ngram_analyzer: [
          tokenizer: "ngram_tokenizer",
          char_filter: ["html_strip", "kuromoji_neologd_iteration_mark"],
          filter: ["lowercase", "kuromoji_neologd_stemmer", "cjk_width"]
        ]
      ],
      tokenizer: [
        ngram_tokenizer: [
          type: "nGram", min_gram: "2", max_gram: "3",
          token_chars: ["letter", "digit"]
        ]
      ],
      filter: [edge_ngram: [type: "edgeNGram", min_gram: 1, max_gram: 15]],
    ]

    assert Schema.__es_analysis__(:type, :analyzer) == [
      ngram_analyzer: [
        tokenizer: "ngram_tokenizer",
        char_filter: ["html_strip", "kuromoji_neologd_iteration_mark"],
        filter: ["lowercase", "kuromoji_neologd_stemmer", "cjk_width"]
      ]
    ]

    assert Schema.__es_analysis__(:type, :tokenizer) == [
      ngram_tokenizer: [type: "nGram", min_gram: "2", max_gram: "3", token_chars: ["letter", "digit"]]
    ]

    assert Schema.__es_analysis__(:type, :filter) == [edge_ngram: [type: "edgeNGram", min_gram: 1, max_gram: 15]]

    assert Schema.__es_analysis__(:type, :unkown) == nil

    assert Schema.__es_analysis__(:settings) == [number_of_replicas: "5", number_of_shards: "10"]
  end

  test "ok schema.analysis.__es_analysis__ with no DSL" do
    assert NoDSLSchema.__es_analysis__(:to_map) == %{
      analysis: %{
        analyzer: %{
          ngram_analyzer: %{
            char_filter: ["html_strip", "kuromoji_iteration_mark"],
            filter: ["lowercase", "kuromoji_stemmer", "cjk_width"],
            tokenizer: "ngram_tokenizer"
          }
        },
        tokenizer: %{
          ngram_tokenizer: %{
            max_gram: "3", min_gram: "2",
            token_chars: ["letter", "digit"], type: "nGram"}
        },
        filter: %{
          edge_ngram: %{
            max_gram: 15, min_gram: 1,
            type: "edgeNGram"
          }
        }
      },
      number_of_replicas: "5",
      number_of_shards: "10"
    }

    assert NoDSLSchema.__es_analysis__(:as_json) == %{
      analysis: %{
        analyzer: %{
          ngram_analyzer: %{
            char_filter: ["html_strip", "kuromoji_iteration_mark"],
            filter: ["lowercase", "kuromoji_stemmer", "cjk_width"],
            tokenizer: "ngram_tokenizer"
          }
        },
        tokenizer: %{
          ngram_tokenizer: %{
            max_gram: "3", min_gram: "2",
            token_chars: ["letter", "digit"], type: "nGram"}
        },
        filter: %{
          edge_ngram: %{
            max_gram: 15, min_gram: 1,
            type: "edgeNGram"
          }
        }
      },
      number_of_replicas: "5",
      number_of_shards: "10"
    }

    assert NoDSLSchema.__es_analysis__(:types) == [
      tokenizer: [ngram_tokenizer: [type: "nGram", token_chars: ["letter", "digit"], min_gram: "2", max_gram: "3"]],
      analyzer: [ngram_analyzer: [tokenizer: "ngram_tokenizer", filter: ["lowercase", "kuromoji_stemmer", "cjk_width"], char_filter: ["html_strip", "kuromoji_iteration_mark"]]],
      filter: [edge_ngram: [type: "edgeNGram", min_gram: 1, max_gram: 15]],
    ]

    assert NoDSLSchema.__es_analysis__(:type, :analyzer) == [
      ngram_analyzer: [tokenizer: "ngram_tokenizer", filter: ["lowercase", "kuromoji_stemmer", "cjk_width"], char_filter: ["html_strip", "kuromoji_iteration_mark"]]
    ]

    assert NoDSLSchema.__es_analysis__(:type, :tokenizer) == [
      ngram_tokenizer: [type: "nGram", token_chars: ["letter", "digit"], min_gram: "2", max_gram: "3"]
    ]

    assert NoDSLSchema.__es_analysis__(:type, :filter) == [edge_ngram: [type: "edgeNGram", min_gram: 1, max_gram: 15]]

    assert NoDSLSchema.__es_analysis__(:type, :unkown) == nil

    assert NoDSLSchema.__es_analysis__(:settings) == [number_of_replicas: "5", number_of_shards: "10"]
  end

end
