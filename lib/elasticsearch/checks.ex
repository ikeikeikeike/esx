defprotocol Elasticsearch.Checks do
  @fallback_to_any true

  def blank?(data)
  def present?(data)
end

defimpl Elasticsearch.Checks, for: Integer do
  alias Elasticsearch.Checks
  def blank?(_),      do: false
  def present?(data), do: not Checks.blank?(data)
end

defimpl Elasticsearch.Checks, for: String do
  alias Elasticsearch.Checks
  def blank?(''),     do: true
  def blank?(' '),    do: true
  def blank?(_),      do: false
  def present?(data), do: not Checks.blank?(data)
end

defimpl Elasticsearch.Checks, for: BitString do
  alias Elasticsearch.Checks
  def blank?(""),     do: true
  def blank?(" "),    do: true
  def blank?(_),      do: false
  def present?(data), do: not Checks.blank?(data)
end

defimpl Elasticsearch.Checks, for: List do
  alias Elasticsearch.Checks
  def blank?([]),     do: true
  def blank?(_),      do: false
  def present?(data), do: not Checks.blank?(data)
end

defimpl Elasticsearch.Checks, for: Tuple do
  alias Elasticsearch.Checks
  def blank?({}),     do: true
  def blank?(_),      do: false
  def present?(data), do: not Checks.blank?(data)
end

defimpl Elasticsearch.Checks, for: Map do
  alias Elasticsearch.Checks
  def blank?(%{}),    do: true
  def blank?(_),      do: false
  def present?(data), do: not Checks.blank?(data)
end

defimpl Elasticsearch.Checks, for: Atom do
  alias Elasticsearch.Checks
  def blank?(false),  do: true
  def blank?(nil),    do: true
  def blank?(_),      do: false
  def present?(data), do: not Checks.blank?(data)
end

defimpl Elasticsearch.Checks, for: MapSet do
  alias Elasticsearch.Checks
  def blank?(data),   do: Enum.empty?(data)
  def present?(data), do: not Checks.blank?(data)
end

# defimpl Elasticsearch.Checks, for: Ecto.Date do
  # alias Elasticsearch.Checks
  # def blank?(%Ecto.Date{year: 0, month: 0, day: 0}), do: true
  # def blank?(%Ecto.Date{year: 1, month: 1, day: 1}), do: true
  # def blank?(_), do: false
  # def present?(data), do: not Checks.blank?(data)
# end

defimpl Elasticsearch.Checks, for: Any do
  def blank?(_),      do: false
  def present?(_),    do: false
end
