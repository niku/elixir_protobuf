defmodule Protobuf.Types.String do
  @behaviour Ecto.Type

  def type, do: :string

  def cast(data) when is_binary(data), do: {:ok, data}
  def cast(_), do: :error

  def load(data) when is_binary(data), do: {:ok, data}
  def load(_), do: :error

  def dump(data) when is_binary(data), do: {:ok, data}
  def dump(_), do: :error
end
