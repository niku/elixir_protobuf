defmodule Protobuf.Parser.MSBTest do
  use ExUnit.Case, async: true
  import BitsSigils
  alias Protobuf.Parser.MSB

  test "Protobuf.Parser.MSB.scan(00000001) returns {:ok, 0000001, <<>>}" do
    assert {:ok, ~b(0000001), <<>>} = MSB.scan(~b(00000001))
  end

  test "Protobuf.Parser.MSB.scan(10101100_10000001_00000010_00000001) returns {:ok, 00000_10000000_10101100, 00000001}" do
    assert {:ok, ~b(00000_10000000_10101100), ~b(00000001)} = MSB.scan(~b(10101100_10000001_00000010_00000001))
  end

  test "Protobuf.Parser.MSB.scan(10101100) returns {:error, :no_rest_binary_found}" do
    assert {:error, :no_rest_binary_found} = MSB.scan(~b(10101100))
  end
end
