defmodule ExTokocrypto.Spot.Private.Account do
  import ExTokocrypto.Rest.SpotClient, only: [get: 3]
  alias ExTokocrypto.Rest.SpotClient

  @type credentials :: ExTokocrypto.Credentials.t()
  @type shared_errors :: SpotClient.shared_errors()

  @spec account(credentials) :: {:ok, term} | {:error, shared_errors}
  def account(credentials) do
    with {:ok, data} <- get("/api/v3/account", %{}, credentials) do
      {:ok, ExTokocrypto.Account.new(data)}
    end
  end
end
