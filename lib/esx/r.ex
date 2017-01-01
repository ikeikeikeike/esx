defmodule ESx.R do
  alias ESx.Transport

  require Logger

  @blank_args {"GET", "", %{}, nil}
  def blank_args, do: @blank_args

  def response({:ok, rs}),      do: Poison.decode rs.body
  def response({:error, err}),  do: {:error, err}

  def response!({:ok, body}),   do: body
  def response!({:error, err}), do: raise err

  def status200?(%Transport{} = ts, method, path, params \\ %{}, body \\ nil) do
    case Transport.perform_request(ts, method, path, params, body) do
      {:ok, rs} ->
        rs.status_code == 200
      {:error, _err} ->
        # Logger.info(err)
        false
      _ ->
        false
    end
  end

end
