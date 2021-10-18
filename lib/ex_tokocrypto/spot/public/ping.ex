defmodule ExTokocrypto.Spot.Public.Ping do
  import ExTokocrypto.Rest.SpotClient, only: [get: 2]

  def ping, do: get("/api/v3/ping", %{})
end
