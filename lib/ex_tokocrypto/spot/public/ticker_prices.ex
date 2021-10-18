defmodule ExTokocrypto.Spot.Public.TickerPrices do
  import ExTokocrypto.Rest.SpotClient, only: [get: 2]

  def ticker_prices do
    with {:ok, data} <- get("/api/v3/ticker/price", %{}) do
      {:ok, Enum.map(data, &ExTokocrypto.SymbolPrice.new(&1))}
    end
  end
end
