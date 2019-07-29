defmodule Protobuf.Decoder do
  @moduledoc false

  alias Protobuf.Decoder.Key
  alias Protobuf.Decoder.Value

  def decode(binary) when is_binary(binary) do
    do_decode(binary, %{})
  end

  defp do_decode(<<>>, acc) do
    {:ok, acc}
  end

  defp do_decode(binary, acc) do
    {:ok, key_no, wire_type_no, rest} = Key.parse(binary)
    {:ok, value, rest2} = Value.parse(rest, wire_type_no)
    do_decode(rest2, Map.put(acc, key_no, value))
  end
end
