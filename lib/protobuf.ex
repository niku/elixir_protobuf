defmodule Protobuf do
  @moduledoc """
  Documentation for Protobuf.
  """

  def decode_varint(binary) when is_binary(binary) do
    # See https://developers.google.com/protocol-buffers/docs/encoding#varints
    {bits, rest} = do_decode_varint(binary, <<>>)
    bit_size = bit_size(bits)
    # Convert from bitstrings to integer
    <<number::integer-size(bit_size)>> = bits
    {number, rest}
  end

  defp do_decode_varint(<<0::1, lower7bits::bitstring-size(7), rest::binary>>, accumulator) do
    {<<lower7bits::bitstring-size(7), accumulator::bitstring>>, rest}
  end

  defp do_decode_varint(<<1::1, lower7bits::bitstring-size(7), rest::binary>>, accumulator) do
    do_decode_varint(rest, <<lower7bits::bitstring-size(7), accumulator::bitstring>>)
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
          # TODO
          nil

        2 ->
          # TODO
          nil

        3 ->
          # TODO
          nil

        4 ->
          # TODO
          nil

        5 ->
          # TODO
          nil
      end

    {field_number, value, rest2}
  end
end
