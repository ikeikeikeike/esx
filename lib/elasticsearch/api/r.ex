defmodule Elasticsearch.API.R do

  @blank_args {"GET", "", %{}, nil}
  def blank_args, do: @blank_args

  def response({:ok, rs}), do: Poison.decode rs.body
  def response({:error, err}), do: {:error, err}

  def response!({:ok, rs}), do: rs
  def response!({:error, err}), do: raise err
end
