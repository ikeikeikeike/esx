defmodule ESx.Transport.ServerError do
  defexception [:status, :response, :message]
  @moduledoc """
  Raised
  """

  @http_statuses %{
    300 => "MultipleChoices",
    301 => "MovedPermanently",
    302 => "Found",
    303 => "SeeOther",
    304 => "NotModified",
    305 => "UseProxy",
    307 => "TemporaryRedirect",
    308 => "PermanentRedirect",

    400 => "BadRequest",
    401 => "Unauthorized",
    402 => "PaymentRequired",
    403 => "Forbidden",
    404 => "NotFound",
    405 => "MethodNotAllowed",
    406 => "NotAcceptable",
    407 => "ProxyAuthenticationRequired",
    408 => "RequestTimeout",
    409 => "Conflict",
    410 => "Gone",
    411 => "LengthRequired",
    412 => "PreconditionFailed",
    413 => "RequestEntityTooLarge",
    414 => "RequestURITooLong",
    415 => "UnsupportedMediaType",
    416 => "RequestedRangeNotSatisfiable",
    417 => "ExpectationFailed",
    418 => "ImATeapot",
    421 => "TooManyConnectionsFromThisIP",
    426 => "UpgradeRequired",
    450 => "BlockedByWindowsParentalControls",
    494 => "RequestHeaderTooLarge",
    497 => "HTTPToHTTPS",
    499 => "ClientClosedRequest",

    500 => "InternalServerError",
    501 => "NotImplemented",
    502 => "BadGateway",
    503 => "ServiceUnavailable",
    504 => "GatewayTimeout",
    505 => "HTTPVersionNotSupported",
    506 => "VariantAlsoNegotiates",
    510 => "NotExtended"
  }

  def exception(opts) do
    sts = Keyword.fetch!(opts, :status)
    msg = Keyword.fetch!(opts, :message)
    rsp = opts[:response]

    msg = "status=#{sts} message=#{@http_statuses[sts]}: #{msg} "
    %__MODULE__{status: sts, response: rsp, message: msg}
  end

  defdelegate wrap(opts), to: __MODULE__, as: :exception

end

defmodule ESx.Transport.UnknownError do
  defexception [:message, :error]
  @moduledoc """
  Raised
  """

  def exception(opts) do
    err = Keyword.fetch!(opts, :error)
    msg = Keyword.fetch!(opts, :message)

    msg = "`#{inspect msg}` happened: #{inspect err}"
    %__MODULE__{message: msg, error: err}
  end

  defdelegate wrap(opts), to: __MODULE__, as: :exception

end
