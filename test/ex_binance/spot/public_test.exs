defmodule ExBinance.Spot.PublicTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias ExBinance.Spot.Public

  setup_all do
    HTTPoison.start()
  end

  test ".ping returns an empty map" do
    use_cassette "spot/public/ping_ok" do
      assert Public.ping() == {:ok, %{}}
    end
  end

  test ".server_time success return an ok, time tuple" do
    use_cassette "spot/public/server_time_ok" do
      {:ok, server_time} = Public.server_time()
      assert server_time > 0
    end
  end

  test ".exchange_info success returns the trading rules and symbol information" do
    use_cassette "spot/public/get_exchange_info_ok" do
      assert {:ok, %ExBinance.ExchangeInfo{} = info} = Public.exchange_info()
      assert info.timezone == "UTC"
      assert info.server_time != nil

      assert info.rate_limits == [
               %{
                 "interval" => "MINUTE",
                 "limit" => 1200,
                 "rateLimitType" => "REQUEST_WEIGHT",
                 "intervalNum" => 1
               },
               %{
                 "interval" => "SECOND",
                 "limit" => 50,
                 "rateLimitType" => "ORDERS",
                 "intervalNum" => 10
               },
               %{
                 "interval" => "DAY",
                 "limit" => 160_000,
                 "rateLimitType" => "ORDERS",
                 "intervalNum" => 1
               }
             ]

      assert info.exchange_filters == []
      assert [symbol | _] = info.symbols

      assert symbol == %{
               "baseAsset" => "BNB",
               "baseAssetPrecision" => 8,
               "filters" => [
                 %{
                   "filterType" => "PRICE_FILTER",
                   "maxPrice" => "10000.00000000",
                   "minPrice" => "0.01000000",
                   "tickSize" => "0.01000000"
                 },
                 %{
                   "filterType" => "PERCENT_PRICE",
                   "avgPriceMins" => 5,
                   "multiplierDown" => "0.2",
                   "multiplierUp" => "5"
                 },
                 %{
                   "filterType" => "LOT_SIZE",
                   "maxQty" => "9000.00000000",
                   "minQty" => "0.01000000",
                   "stepSize" => "0.01000000"
                 },
                 %{
                   "applyToMarket" => true,
                   "avgPriceMins" => 5,
                   "filterType" => "MIN_NOTIONAL",
                   "minNotional" => "10.00000000"
                 },
                 %{
                   "filterType" => "ICEBERG_PARTS",
                   "limit" => 10
                 },
                 %{
                   "filterType" => "MARKET_LOT_SIZE",
                   "maxQty" => "1000.00000000",
                   "minQty" => "0.00000000",
                   "stepSize" => "0.00000000"
                 },
                 %{
                   "filterType" => "MAX_NUM_ORDERS",
                   "maxNumOrders" => 200
                 },
                 %{
                   "filterType" => "MAX_NUM_ALGO_ORDERS",
                   "maxNumAlgoOrders" => 5
                 }
               ],
               "icebergAllowed" => true,
               "orderTypes" => [
                 "LIMIT",
                 "LIMIT_MAKER",
                 "MARKET",
                 "STOP_LOSS_LIMIT",
                 "TAKE_PROFIT_LIMIT"
               ],
               "quoteAsset" => "BUSD",
               "quotePrecision" => 8,
               "status" => "TRADING",
               "symbol" => "BNBBUSD",
               "baseCommissionPrecision" => 8,
               "isMarginTradingAllowed" => false,
               "isSpotTradingAllowed" => true,
               "ocoAllowed" => true,
               "permissions" => ["SPOT"],
               "quoteAssetPrecision" => 8,
               "quoteCommissionPrecision" => 8,
               "quoteOrderQtyMarketAllowed" => true
             }
    end
  end

  test ".ticker_prices returns a list of prices for every symbol" do
    use_cassette "spot/public/ticker_prices_ok" do
      assert {:ok, symbol_prices} = Public.ticker_prices()

      assert Enum.find(symbol_prices, fn x -> x.symbol == "ETHBTC" end) != nil

      assert symbol_prices |> Enum.count() > 0
    end
  end

  describe ".get_depth" do
    test "returns the bids & asks up to the given depth" do
      use_cassette "spot/public/depth_ok" do
        assert {:ok, order_book} = Public.depth("BTCUSDT", 5)

        assert %ExBinance.OrderBook{} = order_book
        assert Enum.any?(order_book.asks)
        assert Enum.any?(order_book.bids)
        assert order_book.last_update_id != nil
      end
    end

    test "returns an error tuple when the symbol doesn't exist" do
      use_cassette "spot/public/depth_error" do
        assert Public.depth("IDONTEXIST", 1000) == {:error, :bad_symbol}
      end
    end
  end

  describe ".klines" do
    test "returns klines for a given symbol and interval" do
      use_cassette "klines_symbol_interval_ok" do
        {:ok, klines} = Public.klines("BTCUSDT", "1m")

        assert [
                 %ExBinance.Kline{
                   close: "33336.52000000",
                   close_time: 1_624_529_639_999,
                   high: "33336.52000000",
                   low: "33325.49000000",
                   number_of_trades: 28,
                   open: "33334.78000000",
                   open_time: 1_624_529_580_000,
                   quote_asset_volume: "10243.20474104",
                   taker_buy_base_asset_volume: "0.24031200",
                   taker_buy_quote_asset_volume: "8009.99722824",
                   volume: "0.30731600"
                 }
                 | _tail
               ] = klines

        assert length(klines) == 500
      end
    end

    test "returns klines for a given symbol, interval and limit" do
      use_cassette "klines_symbol_interval_limit_ok" do
        {:ok, klines} = Public.klines("BTCUSDT", "1m", 1, nil, nil)

        assert [
                 %ExBinance.Kline{
                   close: "35047.03000000",
                   close_time: 1_624_559_579_999,
                   high: "35047.03000000",
                   low: "34800.01000000",
                   number_of_trades: 37,
                   open: "34970.90000000",
                   open_time: 1_624_559_520_000,
                   quote_asset_volume: "14686.87819470",
                   taker_buy_base_asset_volume: "0.41391700",
                   taker_buy_quote_asset_volume: "14492.85555020",
                   volume: "0.41947200"
                 }
               ] = klines
      end
    end

    test "returns klines for a given symbol, interval, start time, end time and limit" do
      use_cassette "klines_symbol_interval_with_time_and_limit_ok" do
        assert {:ok, klines} =
                 Public.klines("BTCUSDT", "1m", 2, 1_624_438_800_000, 1_624_440_000_000)

        assert [kline_1, kline_2] = klines

        assert kline_1 = %ExBinance.Kline{
                 close: "33784.38000000",
                 close_time: 1_624_438_859_999,
                 high: "33800.00000000",
                 low: "33666.01000000",
                 number_of_trades: 52,
                 open: "33800.00000000",
                 open_time: 1_624_438_800_000,
                 quote_asset_volume: "21900.06475101",
                 taker_buy_base_asset_volume: "0.45358400",
                 taker_buy_quote_asset_volume: "15296.35728097",
                 volume: "0.64906000"
               }

        assert kline_2 ==
                 %ExBinance.Kline{
                   close: "33845.40000000",
                   close_time: 1_624_438_919_999,
                   high: "33845.40000000",
                   low: "33785.58000000",
                   number_of_trades: 35,
                   open: "33789.26000000",
                   open_time: 1_624_438_860_000,
                   quote_asset_volume: "16527.62739828",
                   taker_buy_base_asset_volume: "0.48791700",
                   taker_buy_quote_asset_volume: "16498.06501578",
                   volume: "0.48879200"
                 }
      end
    end
  end
end