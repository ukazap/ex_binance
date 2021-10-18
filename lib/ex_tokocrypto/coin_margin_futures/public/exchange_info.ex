defmodule ExTokocrypto.CoinMarginFutures.Public.ExchangeInfo do
  import ExTokocrypto.Rest.CoinMarginFuturesClient, only: [get: 2]

  def exchange_info do
    with {:ok, data} <- get("/dapi/v1/exchangeInfo", %{}) do
      {:ok, ExTokocrypto.ExchangeInfo.new(data)}
    end
  end
end
