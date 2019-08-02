defmodule Protobuf.Decoder.Value do
  alias Protobuf.Decoder.MSB
  use Bitwise

  @varint 0
  @_64bit 1
  @length_delimited 2
  @start_group 3
  @end_group 4
  @_32bit 5

  def parse(binary, wire_type_no)
      when is_binary(binary) and is_integer(wire_type_no) and
             wire_type_no in [@varint, @_64bit, @length_delimited, @_32bit] do
    scan(binary, wire_type_no)
  end

  def scan(binary, @varint) when is_binary(binary) do
    MSB.scan(binary)
  end

  def scan(binary, @length_delimited) when is_binary(binary) do
    {:ok, bitstring_length, body} = MSB.scan(binary)
    total_size = bit_size(bitstring_length)
    <<length::size(total_size)>> = bitstring_length
    <<value::binary-size(length), rest::binary>> = body
    {:ok, value, rest}
  end
end
