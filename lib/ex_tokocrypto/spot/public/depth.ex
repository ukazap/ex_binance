defmodule ExTokocrypto.Spot.Public.Depth do
  import ExTokocrypto.Rest.SpotClient, only: [get: 2]

  def depth(symbol, limit) do
    with {:ok, data} <- get("/api/v3/depth", %{symbol: symbol, limit: limit}) do
      {:ok, ExTokocrypto.OrderBook.new(data)}
    end
  end
end
