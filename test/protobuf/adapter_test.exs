defmodule Protobuf.AdapterTest do
  use ExUnit.Case, async: true
  import BitsSigils

  alias Protobuf.Adapter

  defmodule MyMessage1 do
    use Ecto.Schema

    @primary_key false

    embedded_schema do
      field(:my_int_field, Protobuf.Types.Int32, default: 0, source: 1)
    end
  end

  Adapter.define(MyAdapter1, message: MyMessage1)

  describe "decode/1" do
    test "Returns `{:ok, message}`, the message is the struct defined by Adapter" do
      assert {:ok, %MyMessage1{my_int_field: 150}} = MyAdapter1.decode(~b(00001000_10010110_00000001))
    end
  end
end
