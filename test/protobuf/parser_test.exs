defmodule Protobuf.ParserTest do
  use ExUnit.Case, async: true
  import BitsSigils

  alias Protobuf.Parser

  test "Protobuf.Parser.parse(00001000_10010110_00000001, proto) returns {:ok, %{1 => 150}}" do
    assert {:ok, %{1 => 150}} = Parser.parse(~b(00001000_10010110_00000001), nil)
  end
end
