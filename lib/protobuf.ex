defmodule Protobuf do
  @moduledoc """
  Documentation for Protobuf.
  """

  import Bitwise

  def decode!(message, binary) do
    decode(message, binary)
  end

  def extract_varint(binary) when is_binary(binary) do
    do_extract_varint(binary, <<>>)
  end

  defp do_extract_varint(<<0::1, lower7bits::bitstring-size(7), rest::binary>>, accumulator) do
    {<<lower7bits::bitstring-size(7), accumulator::bitstring>>, rest}
  end

  defp do_extract_varint(<<1::1, lower7bits::bitstring-size(7), rest::binary>>, accumulator) do
    do_extract_varint(rest, <<lower7bits::bitstring-size(7), accumulator::bitstring>>)
  end

  def decode_varint(binary) when is_binary(binary) do
    # See https://developers.google.com/protocol-buffers/docs/encoding#varints
    {bits, rest} = do_decode_varint(binary, <<>>)
    bit_size = bit_size(bits)
    # Convert from bitstrings to integer
    <<number::integer-size(bit_size)>> = bits
    {number, rest}
  end

  def extract_32bit(<<bits::bitstring-size(32), rest::binary>> = binary) when is_binary(binary) do
    {bits, rest}
  end

  def extract_64bit(<<bits::bitstring-size(64), rest::binary>> = binary) when is_binary(binary) do
    {bits, rest}
  end

  def extract_length_delimited(binary) when is_binary(binary) do
    {length_varint, rest} = decode_varint(binary)
    <<bits::binary-size(length_varint), rest2::binary>> = rest
    {bits, rest2}
  end

  def extract_field(binary) when is_binary(binary) do
    do_extract_field(binary, [])
  end

  defp do_extract_field(<<>>, fields), do: fields

  defp do_extract_field(binary, fields) do
    # See https://developers.google.com/protocol-buffers/docs/encoding#structure
    {bits, rest} = extract_varint(binary)
    wire_type_size = 3
    field_number_size = bit_size(bits) - wire_type_size
    # Convert from bitstrings to integer
    <<field_number::integer-size(field_number_size), wire_type::integer-size(wire_type_size)>> = bits

    {value, rest2} =
      case wire_type do
        0 ->
          extract_varint(rest)

        1 ->
          extract_64bit(rest)

        2 ->
          extract_length_delimited(rest)

        3 ->
          # TODO
          nil

        4 ->
          # TODO
          nil

        5 ->
          extract_32bit(rest)
      end

    do_extract_field(rest2, [{field_number, value} | fields])
  end

  def decode(message, binary) when is_atom(message) and is_binary(binary) do
    sources =
      for field <- message.__schema__(:fields), into: Map.new() do
        {message.__schema__(:field_source, field), {field, message.__schema__(:type, field)}}
      end

    fields =
      extract_field(binary)
      |> Enum.map(fn {field_number, value} ->
        {field_name, field_type} = sources[field_number]

        case field_type do
          :integer ->
            size = bit_size(value)
            <<number::integer-size(size)>> = value
            {field_name, number}

          :string ->
            {field_name, value}
        end
      end)

    struct(message, fields)
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
