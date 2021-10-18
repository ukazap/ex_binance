defmodule ExTokocrypto.UsdMarginFutures.Public.ExchangeInfo do
  import ExTokocrypto.Rest.UsdMarginFuturesClient, only: [get: 2]

  def exchange_info do
    with {:ok, data} <- get("/fapi/v1/exchangeInfo", %{}) do
      {:ok, ExTokocrypto.ExchangeInfo.new(data)}
    end
  end
end
