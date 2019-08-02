defmodule Protobuf.AdapterTest do
  use ExUnit.Case, async: true
  import BitsSigils

  alias Protobuf.Adapter

  describe "An adapter which is bound a message having Int32 field" do
    defmodule MyMessage1 do
      use Ecto.Schema

      @primary_key false

      embedded_schema do
        field(:my_int_field, Protobuf.Types.Int32, default: 0, source: 1)
      end
    end

    Adapter.define(MyAdapter1, message: MyMessage1)

    test "returns `{:ok, %MyMessage1{my_int_field: 0}}` when it runs decode(<<>>). It tests the default value." do
      assert {:ok, %MyMessage1{my_int_field: 0}} == MyAdapter1.decode(<<>>)
    end

    test "returns `{:ok, %MyMessage1{my_int_field: -1}}` when it runs decode(08_80_80_80_80_F8_FF_FF_FF_FF_01). It tests the minimum negative integer of Int32." do
      assert {:ok, %MyMessage1{my_int_field: -2_147_483_648}} ==
               MyAdapter1.decode(:binary.encode_unsigned(0x08_80_80_80_80_F8_FF_FF_FF_FF_01))
    end

    test "returns `{:ok, %MyMessage1{my_int_field: -1}}` when it runs decode(08_FF_FF_FF_FF_FF_FF_FF_FF_FF_01). It tests the maximum negative integer of Int32." do
      assert {:ok, %MyMessage1{my_int_field: -1}} ==
               MyAdapter1.decode(:binary.encode_unsigned(0x08_FF_FF_FF_FF_FF_FF_FF_FF_FF_01))
    end

    test "returns `{:ok, %MyMessage1{my_int_field: 1}}` when it runs decode(00001000_00000001). It tests the minimum positive integer of Int32." do
      assert {:ok, %MyMessage1{my_int_field: 1}} ==
               MyAdapter1.decode(~b(00001000_00000001))
    end

    test "returns `{:ok, %MyMessage1{my_int_field: 1}}` when it runs decode(00001000_00000001). It tests the maximum positive integer of Int32." do
      assert {:ok, %MyMessage1{my_int_field: 2_147_483_647}} ==
               MyAdapter1.decode(:binary.encode_unsigned(0x08_FF_FF_FF_FF_07))
    end
  end

  describe "An adapter which is bound a message having Sint32 field" do
    defmodule MyMessage2 do
      use Ecto.Schema

      @primary_key false

      embedded_schema do
        field(:my_int_field, Protobuf.Types.Sint32, default: 0, source: 1)
      end
    end

    Adapter.define(MyAdapter2, message: MyMessage2)

    test "returns `{:ok, %MyMessage2{my_int_field: 0}}` when it runs decode(<<>>). It tests the default value." do
      assert {:ok, %MyMessage2{my_int_field: 0}} == MyAdapter2.decode(<<>>)
    end

    test "returns `{:ok, %MyMessage2{my_int_field: -1}}` when it runs decode(00001000_00000001). It tests the maximum negative integer of Sint32." do
      assert {:ok, %MyMessage2{my_int_field: -1}} == MyAdapter2.decode(~b(00001000_00000001))
    end

    test "returns `{:ok, %MyMessage2{my_int_field: 1}}` when it runs decode(00001000_00000010). It tests the minimum positive integer of Sint32." do
      assert {:ok, %MyMessage2{my_int_field: 1}} == MyAdapter2.decode(~b(00001000_00000010))
    end

    test "returns `{:ok, %MyMessage2{my_int_field: 2_147_483_647}}` when it runs decode(00001000_11111110_11111111_11111111_11111111_00001111). It tests the maximum positive integer of Sint32." do
      assert {:ok, %MyMessage2{my_int_field: 2_147_483_647}} ==
               MyAdapter2.decode(~b(00001000_11111110_11111111_11111111_11111111_00001111))
    end

    test "returns `{:ok, %MyMessage2{my_int_field: -2_147_483_648}}` when it runs decode(00001000_11111111_11111111_11111111_11111111_00001111). It tests the minimum negative integer of Sint32." do
      assert {:ok, %MyMessage2{my_int_field: -2_147_483_648}} ==
               MyAdapter2.decode(~b(00001000_11111111_11111111_11111111_11111111_00001111))
    end
  end

  describe "An adapter which is bound a message having String field" do
    defmodule MyMessage3 do
      use Ecto.Schema

      @primary_key false

      embedded_schema do
        field(:my_string_field, Protobuf.Types.String, default: "", source: 1)
      end
    end

    Adapter.define(MyAdapter3, message: MyMessage3)

    test "returns `{:ok, %MyMessage3{my_string_field: \"\"}}` when it runs decode(). It tests the default value." do
      assert {:ok, %MyMessage3{my_string_field: ""}} ==
               MyAdapter3.decode(<<>>)
    end

    test "returns `{:ok, %MyMessage3{my_string_field: <<0>>}}` when it runs decode(0x0A_01_00). It tests the minimum value." do
      assert {:ok, %MyMessage3{my_string_field: <<0>>}} ==
               MyAdapter3.decode(:binary.encode_unsigned(0x0A_01_00))
    end

    test "returns `{:ok, %MyMessage3{my_string_field: \"こんにちは\"}}` when it runs decode(0x0A0FE38193E38293E381ABE381A1E381AF). It tests multibyte value." do
      assert {:ok, %MyMessage3{my_string_field: "こんにちは"}} ==
               MyAdapter3.decode(:binary.encode_unsigned(0x0A0FE38193E38293E381ABE381A1E381AF))
    end

    test "returns `{:ok, %MyMessage3{my_string_field: 10 times of \"The quick brown fox jumps over the lazy dog.\"}}`. It tests very long string." do
      expected_value = String.duplicate("The quick brown fox jumps over the lazy dog.", 10)

      actual_value =
        <<10, 184, 3, 84, 104, 101, 32, 113, 117, 105, 99, 107, 32, 98, 114, 111, 119, 110, 32, 102, 111, 120, 32, 106,
          117, 109, 112, 115, 32, 111, 118, 101, 114, 32, 116, 104, 101, 32, 108, 97, 122, 121, 32, 100, 111, 103, 46,
          84, 104, 101, 32, 113, 117, 105, 99, 107, 32, 98, 114, 111, 119, 110, 32, 102, 111, 120, 32, 106, 117, 109,
          112, 115, 32, 111, 118, 101, 114, 32, 116, 104, 101, 32, 108, 97, 122, 121, 32, 100, 111, 103, 46, 84, 104,
          101, 32, 113, 117, 105, 99, 107, 32, 98, 114, 111, 119, 110, 32, 102, 111, 120, 32, 106, 117, 109, 112, 115,
          32, 111, 118, 101, 114, 32, 116, 104, 101, 32, 108, 97, 122, 121, 32, 100, 111, 103, 46, 84, 104, 101, 32,
          113, 117, 105, 99, 107, 32, 98, 114, 111, 119, 110, 32, 102, 111, 120, 32, 106, 117, 109, 112, 115, 32, 111,
          118, 101, 114, 32, 116, 104, 101, 32, 108, 97, 122, 121, 32, 100, 111, 103, 46, 84, 104, 101, 32, 113, 117,
          105, 99, 107, 32, 98, 114, 111, 119, 110, 32, 102, 111, 120, 32, 106, 117, 109, 112, 115, 32, 111, 118, 101,
          114, 32, 116, 104, 101, 32, 108, 97, 122, 121, 32, 100, 111, 103, 46, 84, 104, 101, 32, 113, 117, 105, 99,
          107, 32, 98, 114, 111, 119, 110, 32, 102, 111, 120, 32, 106, 117, 109, 112, 115, 32, 111, 118, 101, 114, 32,
          116, 104, 101, 32, 108, 97, 122, 121, 32, 100, 111, 103, 46, 84, 104, 101, 32, 113, 117, 105, 99, 107, 32, 98,
          114, 111, 119, 110, 32, 102, 111, 120, 32, 106, 117, 109, 112, 115, 32, 111, 118, 101, 114, 32, 116, 104, 101,
          32, 108, 97, 122, 121, 32, 100, 111, 103, 46, 84, 104, 101, 32, 113, 117, 105, 99, 107, 32, 98, 114, 111, 119,
          110, 32, 102, 111, 120, 32, 106, 117, 109, 112, 115, 32, 111, 118, 101, 114, 32, 116, 104, 101, 32, 108, 97,
          122, 121, 32, 100, 111, 103, 46, 84, 104, 101, 32, 113, 117, 105, 99, 107, 32, 98, 114, 111, 119, 110, 32,
          102, 111, 120, 32, 106, 117, 109, 112, 115, 32, 111, 118, 101, 114, 32, 116, 104, 101, 32, 108, 97, 122, 121,
          32, 100, 111, 103, 46, 84, 104, 101, 32, 113, 117, 105, 99, 107, 32, 98, 114, 111, 119, 110, 32, 102, 111,
          120, 32, 106, 117, 109, 112, 115, 32, 111, 118, 101, 114, 32, 116, 104, 101, 32, 108, 97, 122, 121, 32, 100,
          111, 103, 46>>

      assert {:ok, %MyMessage3{my_string_field: expected_value}} ==
               MyAdapter3.decode(actual_value)
    end
  end
end
