defmodule Protobuf.ZigZag do
  import Bitwise

  # To use Signed Integers, see
  # https://developers.google.com/protocol-buffers/docs/encoding#signed-integers

  def decode(non_neg_integer) when is_integer(non_neg_integer) and 0 <= non_neg_integer do
    (non_neg_integer >>> 1) ^^^ -(non_neg_integer &&& 1)
  end
end
