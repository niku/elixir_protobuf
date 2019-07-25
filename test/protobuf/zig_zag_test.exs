defmodule Protobuf.ZigZagTest do
  use ExUnit.Case, async: true

  alias Protobuf.ZigZag

  describe "decode/1" do
    test "returns 0 when given 0. It tests the minimum value as argument" do
      assert 0 == ZigZag.decode(0)
    end

    test "returns -1 when given 1. It tests the minimum negative value" do
      assert -1 == ZigZag.decode(1)
    end

    test "returns 1 when given 1. It tests the minimum positive value" do
      assert 1 == ZigZag.decode(2)
    end

    test "returns 2_147_483_647 when given 0xFF_FF_FF_FE (4294967294). It tests the maximum positive value of 32bit" do
      assert 2_147_483_647 == ZigZag.decode(0xFF_FF_FF_FE)
    end

    test "returns -2_147_483_648 when given 0xFF_FF_FF_FF (4294967295). It tests the maximum negative value of 32bit" do
      assert -2_147_483_648 == ZigZag.decode(0xFF_FF_FF_FF)
    end

    test "returns 9_223_372_036_854_775_807 when given 0xFF_FF_FF_FF_FF_FF_FF_FE (18446744073709551614). It tests the maximum positive value of 64bit" do
      assert 9_223_372_036_854_775_807 == ZigZag.decode(0xFF_FF_FF_FF_FF_FF_FF_FE)
    end

    test "returns -9_223_372_036_854_775_808 when given 0xFF_FF_FF_FF_FF_FF_FF_FF (18446744073709551615). It tests the maximum negative value of 64bit" do
      assert -9_223_372_036_854_775_808 == ZigZag.decode(0xFF_FF_FF_FF_FF_FF_FF_FF)
    end
  end
end
