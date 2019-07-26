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

    test "returns `{:ok, %MyMessage1{my_int_field: 150}}` when it runs decode(00001000_10010110_00000001)" do
      assert {:ok, %MyMessage1{my_int_field: 150}} == MyAdapter1.decode(~b(00001000_10010110_00000001))
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

    test "returns `{:ok, %MyMessage2{my_int_field: 0}}` when it runs decode(00001000_00000000). It tests the value having all zero bit of Sint32." do
      assert {:ok, %MyMessage2{my_int_field: 0}} == MyAdapter2.decode(~b(00001000_00000000))
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
end
