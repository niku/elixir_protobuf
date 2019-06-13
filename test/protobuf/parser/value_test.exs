defmodule Protobuf.Parser.ValueTest do
  use ExUnit.Case, async: true
  import BitsSigils

  alias Protobuf.Parser.Value

  test "Protobuf.Parser.Value.parse(10010110_00000001, 0, :integer) returns {:ok, 150, <<>>}" do
    assert {:ok, 150, <<>>} = Value.parse(~b(10010110_00000001), 0, Protobuf.Types.Int32)
  end

  test "Protobuf.Parser.Value.parse(00000001, 0, :sint32) returns {:ok, -1, <<>>}" do
    assert {:ok, -1, <<>>} = Value.parse(~b(00000001), 0, Protobuf.Types.Sint32)
  end
end
