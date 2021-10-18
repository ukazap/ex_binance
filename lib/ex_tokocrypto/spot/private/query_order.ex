defmodule ExTokocrypto.Spot.Private.QueryOrder do
  import ExTokocrypto.Rest.SpotClient, only: [get: 3]
  alias ExTokocrypto.Rest.SpotClient
  alias ExTokocrypto.Spot.Private.Responses
  alias ExTokocrypto.{Timestamp, Credentials}

  @type symbol :: String.t()
  @type order_id :: String.t()
  @type client_order_id :: String.t()
  @type credentials :: Credentials.t()
  @type response :: Responses.QueryOrderResponse.t()
  @type error_msg :: String.t()
  @type error_reason :: {:not_found, error_msg} | SpotClient.shared_errors()

  @path "/api/v3/order"
  @receiving_window 5000

  @spec query_order_by_order_id(symbol, order_id, credentials) ::
          {:ok, response} | {:error, error_reason}
  def query_order_by_order_id(symbol, order_id, credentials) do
    params = %{
      symbol: symbol,
      orderId: order_id,
      timestamp: Timestamp.now(),
      recv_window: @receiving_window
    }

    @path
    |> get(params, credentials)
    |> parse_response()
  end

  @spec query_order_by_client_order_id(symbol, client_order_id, credentials) ::
          {:ok, response} | {:error, error_reason}
  def query_order_by_client_order_id(symbol, client_order_id, credentials) do
    params = %{
      symbol: symbol,
      origClientOrderId: client_order_id,
      timestamp: Timestamp.now(),
      recv_window: @receiving_window
    }

    @path
    |> get(params, credentials)
    |> parse_response()
  end

  defp parse_response({:ok, response}) do
    {:ok, Responses.QueryOrderResponse.new(response)}
  end

  defp parse_response({:error, {:tokocrypto_error, %{"code" => -2013, "msg" => msg}}}) do
    {:error, {:not_found, msg}}
  end

  defp parse_response({:error, _} = error) do
    error
  end
end