defmodule ProtobufTest do
  use ExUnit.Case, async: true
  doctest Protobuf

  def sigil_b(term, _modifiers) do
    for <<i <- term>>, i in [?0, ?1], do: <<i::1>>, into: <<>>
  end

  def sigil_B(term, modifiers) do
    sigil_b(term, modifiers)
  end

  describe "decode_varint/1" do
    test "0000_0001 converts to 1" do
      assert {1, <<>>} = Protobuf.decode_varint(~b(0000_0001))
    end

    test "1010_1100_0000_0010 converts to 300" do
      assert {300, <<>>} = Protobuf.decode_varint(~b(1010_1100_0000_0010))
    end
  end

  describe "decode_field_number_and_value/1" do
    test "0000_1000_1001_0110_0000_0001 converts 1 as a field and 150 as a value" do
      assert {1, 150, <<>>} = Protobuf.decode_field_number_and_value(~b(0000_1000_1001_0110_0000_0001))
    end
  end
end
