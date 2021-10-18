defmodule ExTokocrypto.Timestamp do
  def now, do: :os.system_time(:millisecond)
end
