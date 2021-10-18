defmodule ExTokocrypto.Spot.Private.CancelAllOrders do
  import ExTokocrypto.Rest.SpotClient, only: [delete: 3]
  alias ExTokocrypto.Rest.SpotClient
  alias ExTokocrypto.Spot.Private.Responses
  alias ExTokocrypto.Timestamp

  @type symbol :: String.t()
  @type credentials :: ExTokocrypto.Credentials.t()
  @type response :: Responses.CancelOrderResponse.t()
  @type error_msg :: String.t()
  @type error_reason :: {:not_found, error_msg} | SpotClient.shared_errors()

  @path "/api/v3/openOrders"
  @receiving_window 5000

  @spec cancel_all_orders(symbol, credentials) :: {:ok, response} | {:error, error_reason}
  def cancel_all_orders(symbol, credentials) do
    params = %{
      symbol: symbol,
      timestamp: Timestamp.now(),
      recv_window: @receiving_window
    }

    @path
    |> delete(params, credentials)
    |> parse_response()
  end

  defp parse_response({:ok, response}) do
    result =
      Enum.reduce(response, [], fn
        %{"orderId" => _} = r, acc ->
          [Responses.CancelOrderResponse.new(r) | acc]

        _, acc ->
          acc
      end)

    {:ok, result}
  end

  defp parse_response({:error, {:tokocrypto_error, %{"code" => -2011, "msg" => msg}}}) do
    {:error, {:not_found, msg}}
  end

  defp parse_response({:error, _} = error) do
    error
  end
end
