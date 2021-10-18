defmodule ExTokocrypto.CoinMarginFutures.Public.ServerTime do
  import ExTokocrypto.Rest.CoinMarginFuturesClient, only: [get: 2]

  def server_time do
    with {:ok, %{"serverTime" => time}} <- get("/dapi/v1/time", %{}) do
      {:ok, time}
    end
  end
end
