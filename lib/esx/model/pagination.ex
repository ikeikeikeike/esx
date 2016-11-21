defimpl Scrivener.Paginater, for: ESx.Model.Response do
  alias Scrivener.{Config, Page}

  @moduledoc false

  @spec paginate(ESx.Model.Response.t, Scrivener.Config.t) :: Scrivener.Page.t
  def paginate(response, %Config{page_size: page_size, page_number: page_number}) do
    total_entries = response.total
    entries = response.records || response.hits

    %Page{
      page_size: page_size,
      page_number: page_number,
      entries: entries,
      total_entries: total_entries,
      total_pages: total_pages(total_entries, page_size)
    }
  end

  def distance(response) do
    %{
      prev_page: response.page_number - 1,
      next_page: response.page_number + 1,
      has_prev: response.page_number > 1,
      has_next: response.page_number < response.total_pages
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
