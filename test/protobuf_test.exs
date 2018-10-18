defmodule ProtobufTest do
  use ExUnit.Case, async: true
  doctest Protobuf

  def sigil_b(term, _modifiers) do
    for <<i <- term>>, i in [?0, ?1], do: <<i::1>>, into: <<>>
  end

  def sigil_B(term, modifiers) do
    sigil_b(term, modifiers)
  end

  def sigil_h(term, _modifiers) do
    for i <- String.graphemes(term), String.match?(i, ~r/[0-9A-Fa-f]/), into: <<>> do
      <<_::bitstring-size(4), bits::bitstring-size(4)>> =
        String.to_integer(i, 16)
        |> :binary.encode_unsigned()

      bits
    end
  end

  def sigil_H(term, modifiers) do
    sigil_h(term, modifiers)
  end

  defmodule MyMessage do
    use Ecto.Schema

    @primary_key false

    embedded_schema do
      field(:my_int_field, :integer, default: 0, source: 1)
      field(:my_string_field, :string, default: "", source: 2)
    end
  end

  test "decode/2" do
    assert %MyMessage{my_int_field: 150, my_string_field: "testing"} =
             Protobuf.decode(MyMessage, ~h(08_96_01_12_07_74_65_73_74_69_6e_67))
  end

  describe "extract_varint/1" do
    test "0000_0001 is extracted to 000_001" do
      extracted = ~b(000_0001)
      assert {^extracted, <<>>} = Protobuf.extract_varint(~b(0000_0001))
    end

    test "1010_1100_0000_0010 is extracted to 00_0001_0010_1100" do
      extracted = ~b(00_0001_0010_1100)
      assert {^extracted, <<>>} = Protobuf.extract_varint(~b(1010_1100_0000_0010))
    end

    test "1010_1100_0000_0010_0000_0001 is extracted to 00_0001_0010_1100, and the rest is 0000_0001" do
      extracted = ~b(00_0001_0010_1100)
      rest = ~b(0000_0001)
      assert {^extracted, ^rest} = Protobuf.extract_varint(~b(1010_1100_0000_0010_0000_0001))
    end
  end

  describe "extract_32bit/1" do
    test "0000_0000_0000_0000_0000_0000_0000_0000 is extracted to 0000_0000_0000_0000_0000_0000_0000_0000" do
      extracted = ~b(0000_0000_0000_0000_0000_0000_0000_0000)
      assert {^extracted, <<>>} = Protobuf.extract_32bit(~b(0000_0000_0000_0000_0000_0000_0000_0000))
    end

    test "1111_1111_1111_1111_1111_1111_1111_1111_0000_0001 is extracted to 1111_1111_1111_1111_1111_1111_1111_1111, and the rest is 0000_0001" do
      extracted = ~b(1111_1111_1111_1111_1111_1111_1111_1111)
      rest = ~b(0000_0001)
      assert {^extracted, ^rest} = Protobuf.extract_32bit(~b(1111_1111_1111_1111_1111_1111_1111_1111_0000_0001))
    end
  end

  describe "extract_64bit/1" do
    test "0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 is extracted to 0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000" do
      extracted = ~b(0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000)

      assert {^extracted, <<>>} =
               Protobuf.extract_64bit(
                 ~b(0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000)
               )
    end

    test "1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_0000_0001 is extracted to 1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111, and the rest is 00000_0001" do
      extracted = ~b(1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111)
      rest = ~b(0000_0001)

      assert {^extracted, ^rest} =
               Protobuf.extract_64bit(
                 ~b(1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_0000_0001)
               )
    end
  end

  describe "extract_length_delimited/1" do
    test "07_74_65_73_74_69_6e_67 is extracted to 74_65_73_74_69_6e_67" do
      extracted = ~h(74_65_73_74_69_6e_67)
      assert byte_size(extracted) == 7
      assert {^extracted, <<>>} = Protobuf.extract_length_delimited(~h(07_74_65_73_74_69_6e_67))
    end

    test "starting 80_01 means extracting 128 bytes" do
      bytes =
        Stream.repeatedly(fn -> "a" end)
        |> Stream.take(129)
        |> Enum.join()

      {extracted, rest} = Protobuf.extract_length_delimited(~h(80_01) <> bytes)
      assert byte_size(extracted) == 128
      assert byte_size(rest) == 1
    end
  end

  describe "extract_field/1" do
    test "0000_1000_1001_0110_0000_0001 is extracted to [{1, 00_0000_1001_0110}]" do
      extracted = ~b(00_0000_1001_0110)
      assert [{1, ^extracted}] = Protobuf.extract_field(~b(0000_1000_1001_0110_0000_0001))
    end
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

  describe "decode_fixed32/1" do
    test "0000_0000_0000_0000_0000_0000_0000_0000 to 0" do
      assert {0, <<>>} = Protobuf.decode_fixed32(~b(0000_0000_0000_0000_0000_0000_0000_0000))
    end

    test "0000_0000_0000_0000_0000_0000_0000_0001 to 1" do
      assert {1, <<>>} = Protobuf.decode_fixed32(~b(0000_0000_0000_0000_0000_0000_0000_0001))
    end

    test "1111_1111_1111_1111_1111_1111_1111_1111 to 4_294_967_295" do
      assert {4_294_967_295, <<>>} = Protobuf.decode_fixed32(~b(1111_1111_1111_1111_1111_1111_1111_1111))
    end
  end

  describe "decode_string/1" do
    test "07_74_65_73_74_69_6e_67 to testing" do
      assert {"testing", <<>>} = Protobuf.decode_string(~h(07_74_65_73_74_69_6e_67))
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

  test "embedded messages" do
    rest = ~h(08 96 01)
    {3, ^rest, <<>>} = Protobuf.decode_field_number_and_value(~h(1a 03 08 96 01))
  end
end
