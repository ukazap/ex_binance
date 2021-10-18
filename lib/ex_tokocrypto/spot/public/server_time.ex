defmodule ExTokocrypto.Spot.Public.ServerTime do
  import ExTokocrypto.Rest.SpotClient, only: [get: 2]

  def server_time, do: ExTokocrypto.LegacyMode.maybe_use_legacy_mode() |> server_time()

  defp server_time(:legacy_mode) do
    with {:ok, %{"timestamp" => time}} <- get("/open/v1/common/time", %{}) do
      {:ok, time}
    end
  end

  defp server_time(_) do
    with {:ok, %{"serverTime" => time}} <- get("/api/v3/time", %{}) do
      {:ok, time}
    end
  end
end
