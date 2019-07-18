defmodule Protobuf.Types.Sint32 do
  @behaviour Ecto.Type

  import Bitwise

  def type, do: :integer

  def cast(data) when is_integer(data), do: {:ok, data}
  def cast(_), do: :error

  def load(data) when is_integer(data) and 0 <= data, do: {:ok, (data >>> 1) ^^^ -(data &&& 1)}

  def dump(data) when is_integer(data), do: {:ok, data}
  def dump(_), do: :error
end
