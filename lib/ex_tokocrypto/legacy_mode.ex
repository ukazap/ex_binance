defmodule ExTokocrypto.LegacyMode do
  @moduledoc """
  Check for legacy API (Tokocrypto)
  """

  def maybe_use_legacy_mode do
    case Application.get_env(:ex_tokocrypto, :legacy_mode) do
      true -> :legacy_mode
      _ -> nil
    end
  end
end
