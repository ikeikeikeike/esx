defmodule ESx.Model.Pagination do

  defstruct [
    entries: [],
    page_size: 0, page_number: 0, prev_page: 0, next_page: 0,
    has_prev: false, has_next: false,
    total_entries: 0, total_pages: 0,
  ]

  def paginate(%{recourds: recourds, total: total} = _resp, opts) do
    page = opts[:page]
    page_size = opts[:per_page]
    pages = total_pages(total, page_size)

    %{
      entries: recourds,
      page_size: opts[:page_size],
      page_number: page,
      prev_page: page - 1,
      next_page: page + 1,
      has_prev: page > 1,
      has_next: page < pages,
      total_entries: total,
      total_pages: pages,
    }
  end

  defp total_pages(total_entries, page_size) do
    ceiling(total_entries / page_size)
  end

  defp ceiling(float) do
    t = trunc(float)

    case float - t do
      neg when neg < 0 ->
        t
      pos when pos > 0 ->
        t + 1
      _ -> t
    end
  end

end
