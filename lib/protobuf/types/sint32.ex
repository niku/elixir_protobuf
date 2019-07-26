defmodule Protobuf.Types.Sint32 do
  @behaviour Ecto.Type

  alias Protobuf.ZigZag

  def type, do: :integer

  def cast(data) when is_integer(data), do: {:ok, data}
  def cast(_), do: :error

  def load(data) when is_integer(data) and 0 <= data, do: {:ok, ZigZag.decode(data)}
  def load(_), do: :error

  def dump(data) when is_integer(data), do: {:ok, data}
  def dump(_), do: :error
end
