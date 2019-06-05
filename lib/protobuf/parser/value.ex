defmodule Protobuf.Parser.Value do
  alias Protobuf.Parser.MSB
  use Bitwise

  @varint 0
  @_64bit 1
  @length_delimited 2
  @start_group 3
  @end_group 4
  @_32bit 5

  def parse(binary, wire_type_no, value_type) do
    {:ok, bitstring, rest} = scan(binary, wire_type_no)
    {:ok, value} = convert(bitstring, value_type)
    {:ok, value, rest}
  end

  def scan(binary, @varint) do
    MSB.scan(binary)
  end

  def convert(bitstring, :int32) do
    total_size = bit_size(bitstring)
    <<i::size(total_size)>> = bitstring
    {:ok, i}
  end

  def convert(bitstring, :sint32) do
    total_size = bit_size(bitstring)
    <<i::size(total_size)>> = bitstring
    {:ok, (i >>> 1) ^^^ -(i &&& 1)}
  end
end
