defmodule Protobuf.Types.Int32 do
  @behaviour Ecto.Type

  def type, do: :integer

  def cast(data) when is_integer(data), do: {:ok, data}
  def cast(_), do: :error

  def load(data) when is_integer(data), do: {:ok, data}

  def dump(data) when is_integer(data), do: {:ok, data}
  def dump(_), do: :error
end
