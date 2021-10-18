defmodule ExTokocrypto.UsdMarginFutures.Public.Ping do
  import ExTokocrypto.Rest.UsdMarginFuturesClient, only: [get: 2]

  def ping, do: get("/fapi/v1/ping", %{})
end
