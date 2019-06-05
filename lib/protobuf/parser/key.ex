defmodule Protobuf.Parser.Key do
  alias Protobuf.Parser.MSB

  @wire_type_size 3

  def parse(binary) when is_binary(binary) do
    {:ok, bitstring, rest} = MSB.scan(binary)
    total_size = bit_size(bitstring)
    key_size = total_size - @wire_type_size
    <<key_no::size(key_size), wire_type_no::size(@wire_type_size)>> = bitstring
    {:ok, key_no, wire_type_no, rest}
  end
end
