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

  describe "decode_fixed64/1" do
    test "0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 to 0" do
      assert {0, <<>>} =
               Protobuf.decode_fixed64(
                 ~b(0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000)
               )
    end

    test "0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001 to 1" do
      assert {1, <<>>} =
               Protobuf.decode_fixed64(
                 ~b(0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001)
               )
    end

    test "1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 to 18446744073709551615" do
      assert {18_446_744_073_709_551_615, <<>>} =
               Protobuf.decode_fixed64(
                 ~b(1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111)
               )
    end
  end

  describe "decode_field_number_and_value/1" do
    test "0000_1000_1001_0110_0000_0001 converts 1 as a field and 150 as a value" do
      assert {1, 150, <<>>} = Protobuf.decode_field_number_and_value(~b(0000_1000_1001_0110_0000_0001))
    end
  end

  describe "decode_zig_zag/1" do
    test "0 converts to 0" do
      assert Protobuf.decode_zig_zag(0) == 0
    end

    test "1 converts to -1" do
      assert Protobuf.decode_zig_zag(1) == -1
    end

    test "2 converts to 1" do
      assert Protobuf.decode_zig_zag(2) == 1
    end

    test "3 converts to -2" do
      assert Protobuf.decode_zig_zag(3) == -2
    end

    test "4_294_967_294 converts to 2_147_483_647" do
      assert Protobuf.decode_zig_zag(4_294_967_294) == 2_147_483_647
    end

    test "4_294_967_295 converts to -2_147_483_648" do
      assert Protobuf.decode_zig_zag(4_294_967_295) == -2_147_483_648
    end
  end
end
