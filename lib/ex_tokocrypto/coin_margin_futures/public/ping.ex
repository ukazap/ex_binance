defmodule ExTokocrypto.CoinMarginFutures.Public.Ping do
  import ExTokocrypto.Rest.CoinMarginFuturesClient, only: [get: 2]

  def ping, do: get("/dapi/v1/ping", %{})
end
