defmodule Protobuf.Decoder.KeyTest do
  use ExUnit.Case, async: true
  import BitsSigils

  alias Protobuf.Decoder.Key

  test "Protobuf.Decoder.Key.parse(00001000_10010110_00000001) returns {:ok, 1, 0, <<150, 1>>}" do
    assert {:ok, 1, 0, <<150, 1>>} = Key.parse(~b(00001000_10010110_00000001))
  end
end
