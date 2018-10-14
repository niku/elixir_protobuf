defmodule Protobuf do
  @moduledoc """
  Documentation for Protobuf.
  """

  import Bitwise

  def decode_varint(binary) when is_binary(binary) do
    # See https://developers.google.com/protocol-buffers/docs/encoding#varints
    {bits, rest} = do_decode_varint(binary, <<>>)
    bit_size = bit_size(bits)
    # Convert from bitstrings to integer
    <<number::integer-size(bit_size)>> = bits
    {number, rest}
  end

  def decode_fixed32(<<number::32, rest::binary>> = binary) when is_binary(binary) do
    {number, rest}
  end

  def decode_fixed64(<<number::64, rest::binary>> = binary) when is_binary(binary) do
    {number, rest}
  end

  defp do_decode_varint(<<0::1, lower7bits::bitstring-size(7), rest::binary>>, accumulator) do
    {<<lower7bits::bitstring-size(7), accumulator::bitstring>>, rest}
  end

  defp do_decode_varint(<<1::1, lower7bits::bitstring-size(7), rest::binary>>, accumulator) do
    do_decode_varint(rest, <<lower7bits::bitstring-size(7), accumulator::bitstring>>)
  end

  def decode_string(binary) when is_binary(binary) do
    {length_varint, rest} = decode_varint(binary)
    <<values::binary-size(length_varint), rest2::binary>> = rest
    {values, rest2}
  end

  def decode_field_number_and_value(binary) when is_binary(binary) do
    # See https://developers.google.com/protocol-buffers/docs/encoding#structure
    {bits, rest} = do_decode_varint(binary, <<>>)
    wire_type_size = 3
    field_size = bit_size(bits) - wire_type_size
    # Convert from bitstrings to integer
    <<field_number::integer-size(field_size), wire_type::integer-size(wire_type_size)>> = bits

    {value, rest2} =
      case wire_type do
        0 ->
          decode_varint(rest)

        1 ->
          # See https://developers.google.com/protocol-buffers/docs/encoding#non-varint-numbers
          decode_fixed64(rest)

        2 ->
          # See https://developers.google.com/protocol-buffers/docs/encoding#strings
          decode_string(rest)

        3 ->
          # TODO
          nil

        4 ->
          # TODO
          nil

        5 ->
          # See https://developers.google.com/protocol-buffers/docs/encoding#non-varint-numbers
          decode_fixed32(rest)
      end

    {field_number, value, rest2}
  end

  def decode_zig_zag(n) when is_integer(n) and 0 <= n do
    # https://developers.google.com/protocol-buffers/docs/encoding#signed-integers
    (n >>> 1) ^^^ -(n &&& 1)
  end
end
