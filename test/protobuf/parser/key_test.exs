defmodule Protobuf.Parser.KeyTest do
  use ExUnit.Case, async: true
  import BitsSigils

  alias Protobuf.Parser.Key

  test "Protobuf.Parser.Key.parse(00001000_10010110_00000001) returns {:ok, 1, 0, <<150, 1>>}" do
    assert {:ok, 1, 0, <<150, 1>>} = Key.parse(~b(00001000_10010110_00000001))
  end
end
