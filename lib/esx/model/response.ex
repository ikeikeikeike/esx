defmodule ESx.Model.Response do

  def records do
  end

  def took do
    # response['took']
  end

  def timed_out do
    # response['timed_out']
  end

  def shards do
    # Hashie::Mash.new(response['_shards'])
    # response['_shards']
  end

  def aggregations do
    # Aggregations.new(response['aggregations'])
  end

  def suggestions do
    # Suggestions.new(response['suggest'])
  end
end
