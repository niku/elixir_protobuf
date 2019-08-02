defmodule Protobuf.Types.Sint32 do
  @behaviour Ecto.Type
  @max_bit_size 32

  alias Protobuf.ZigZag

  def type, do: :integer

  def cast(data) when is_integer(data), do: {:ok, data}
  def cast(_), do: :error

  def load(data) when is_bitstring(data) do
    data_bit_size = bit_size(data)

    if data_bit_size <= @max_bit_size do
      <<i::unsigned-integer-size(data_bit_size)>> = data
      {:ok, ZigZag.decode(i)}
    else
      discard_bit_size = data_bit_size - @max_bit_size
      <<_::size(discard_bit_size), i::unsigned-integer-size(@max_bit_size)>> = data
      {:ok, ZigZag.decode(i)}
    end
  end

  def load(_), do: :error

  def dump(data) when is_integer(data), do: {:ok, data}
  def dump(_), do: :error
end
