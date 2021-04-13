defmodule ExBinance.Rest.HTTPClient do
  alias ExBinance.Credentials

  @type credentials :: Credentials.t()
  @type path :: String.t()
  @type header :: {key :: String.t(), value :: String.t()}
  @type config_error :: {:config_missing, String.t()}
  @type shared_errors ::
          :timeout
          | :connect_timeout
          | {:http_error, any}
          | {:decode_error, Jason.DecodeError.t()}
          | :bad_symbol
          | :receive_window
          | {:binance_error, map}

  @receive_window 5000
  @api_key_header "X-MBX-APIKEY"

  @spec get(path, map, [header] | credentials, keyword) :: {:ok, any} | {:error, shared_errors}
  def get(path, params, headers \\ [], opts \\ [])

  def get(path, params, headers, _opts) when is_map(params) and is_list(headers) do
    query = URI.encode_query(params)
    uri = %URI{path: path, query: query} |> URI.to_string()

    [endpoint(), uri]
    |> Path.join()
    |> HTTPoison.get(headers)
    |> parse_response
  end

  def get(path, params, %Credentials{} = credentials, opts) when is_map(params) do
    :get
    |> request(path, params, credentials, opts)
    |> parse_response()
  end

  @spec post(String.t(), map, credentials, keyword) :: {:ok, any} | {:error, shared_errors}
  def post(path, params, %Credentials{} = credentials, opts \\ []) when is_map(params) do
    :post
    |> request(path, params, credentials, opts)
    |> parse_response()
  end

  @spec delete(String.t(), map, credentials, keyword) :: {:ok, any} | {:error, shared_errors}
  def delete(path, params, %Credentials{} = credentials, opts \\ []) when is_map(params) do
    :delete
    |> request(path, params, credentials, opts)
    |> parse_response()
  end

  @spec put(String.t(), map, credentials, keyword) :: {:ok, any} | {:error, shared_errors}
  def put(path, params, %Credentials{} = credentials, opts \\ []) when is_map(params) do
    :put
    |> request(path, params, credentials, opts)
    |> parse_response()
  end

  defp request(:get, path, params, credentials, opts) do
    signed = Keyword.get(opts, :signed, true)
    params = maybe_sign_params(params, credentials.secret_key, signed)

    headers = [{@api_key_header, credentials.api_key}]

    HTTPoison.get("#{endpoint()}#{path}", headers, params: params)
  end

  defp request(method, path, params, credentials, opts) do
    signed = Keyword.get(opts, :signed, true)
    params = maybe_sign_params(params, credentials.secret_key, signed)

    body = URI.encode_query(params)
    headers = [{@api_key_header, credentials.api_key}]

    HTTPoison.request(method, "#{endpoint()}#{path}", body, headers)
  end

  defp maybe_sign_params(params, _api_key, false), do: params

  defp maybe_sign_params(params, api_key, true) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

    params =
      params
      |> Map.put_new(:recvWindow, @receive_window)
      |> Map.put(:timestamp, timestamp)

    query_string = URI.encode_query(params)
    signature = sign(api_key, query_string)

    Map.put(params, :signature, signature)
  end

  defp sign(secret_key, argument_string),
    do: :sha256 |> :crypto.hmac(secret_key, argument_string) |> Base.encode16()

  defp parse_response({:ok, response}) do
    response.body
    |> Jason.decode()
    |> parse_response_body
  end

  defp parse_response({:error, %HTTPoison.Error{id: nil, reason: :timeout}}),
    do: {:error, :timeout}

  defp parse_response({:error, %HTTPoison.Error{id: nil, reason: :connect_timeout}}),
    do: {:error, :connect_timeout}

  defp parse_response({:error, err}), do: {:error, {:http_error, err}}

  defp parse_response_body({:ok, %{"code" => -1121}}), do: {:error, :bad_symbol}
  defp parse_response_body({:ok, %{"code" => -1021}}), do: {:error, :receive_window}
  defp parse_response_body({:ok, %{"code" => _} = reason}), do: {:error, {:binance_error, reason}}
  defp parse_response_body({:ok, _} = result), do: result
  defp parse_response_body({:error, err}), do: {:error, {:decode_error, err}}

  def endpoint, do: "https://#{domain()}"
  def domain, do: Application.get_env(:ex_binance, :domain, "api.binance.com")
end
