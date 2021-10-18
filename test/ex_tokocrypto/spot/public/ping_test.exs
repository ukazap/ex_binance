defmodule ExTokocrypto.Spot.Public.PingTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias ExTokocrypto.Spot.Public

  setup_all do
    HTTPoison.start()
  end

  test ".ping returns an empty map" do
    use_cassette "spot/public/ping_ok" do
      assert Public.ping() == {:ok, %{}}
    end
  end
end
