defmodule ExTokocrypto.Spot.Public.ExchangeInfo do
  import ExTokocrypto.Rest.SpotClient, only: [get: 2]

  def exchange_info, do: ExTokocrypto.LegacyMode.maybe_use_legacy_mode() |> exchange_info()

  defp exchange_info(:legacy_mode) do
    with {
           :ok,
           %{
             "timestamp" => server_time,
             "data" => %{"list" => symbols}
           }
         } <- get("/open/v1/common/symbols", %{}) do
      {:ok, ExTokocrypto.ExchangeInfo.new(server_time: server_time, symbols: symbols)}
    end
  end

  defp exchange_info(_) do
    with {:ok, data} <- get("/api/v3/exchangeInfo", %{}) do
      {:ok, ExTokocrypto.ExchangeInfo.new(data)}
    end
  end
end
