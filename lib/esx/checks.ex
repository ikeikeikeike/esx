defprotocol ESx.Checks do
  @fallback_to_any true

  def blank?(data)
  def present?(data)
end

defimpl ESx.Checks, for: Integer do
  alias ESx.Checks
  def blank?(_),      do: false
  def present?(data), do: not Checks.blank?(data)
end

defimpl ESx.Checks, for: String do
  alias ESx.Checks
  def blank?(''),     do: true
  def blank?(' '),    do: true
  def blank?(_),      do: false
  def present?(data), do: not Checks.blank?(data)
end

defimpl ESx.Checks, for: BitString do
  alias ESx.Checks
  def blank?(""),     do: true
  def blank?(" "),    do: true
  def blank?(_),      do: false
  def present?(data), do: not Checks.blank?(data)
end

defimpl ESx.Checks, for: List do
  alias ESx.Checks
  def blank?([]),     do: true
  def blank?(_),      do: false
  def present?(data), do: not Checks.blank?(data)
end

defimpl ESx.Checks, for: Tuple do
  alias ESx.Checks
  def blank?({}),     do: true
  def blank?(_),      do: false
  def present?(data), do: not Checks.blank?(data)
end

defimpl ESx.Checks, for: Map do
  alias ESx.Checks
  def blank?(%{}),    do: true
  def blank?(_),      do: false
  def present?(data), do: not Checks.blank?(data)
end

defimpl ESx.Checks, for: Atom do
  alias ESx.Checks
  def blank?(false),  do: true
  def blank?(nil),    do: true
  def blank?(_),      do: false
  def present?(data), do: not Checks.blank?(data)
end

defimpl ESx.Checks, for: MapSet do
  alias ESx.Checks
  def blank?(data),   do: Enum.empty?(data)
  def present?(data), do: not Checks.blank?(data)
end

# defimpl ESx.Checks, for: Ecto.Date do
  # alias ESx.Checks
  # def blank?(%Ecto.Date{year: 0, month: 0, day: 0}), do: true
  # def blank?(%Ecto.Date{year: 1, month: 1, day: 1}), do: true
  # def blank?(_), do: false
  # def present?(data), do: not Checks.blank?(data)
# end

defimpl ESx.Checks, for: Any do
  def blank?(_),      do: false
  def present?(_),    do: false
end
