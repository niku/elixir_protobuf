defmodule Protobuf.Parser.ValueTest do
  use ExUnit.Case, async: true
  import BitsSigils

  alias Protobuf.Parser.Value

  test "Protobuf.Parser.Value.parse(10010110_00000001, 0) returns {:ok, 150, <<>>}" do
    assert {:ok, 150, <<>>} = Value.parse(~b(10010110_00000001), 0)
  end
end
