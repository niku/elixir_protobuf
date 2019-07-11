defmodule Protobuf.Decoder.MSB do
  @moduledoc false

  # Scan bytes which have MSB(Most significant bit)
  def scan(binary) when is_binary(binary) do
    do_scan(<<>>, binary)
  end

  defp do_scan(progress, <<0::1, lower7bits::bitstring-size(7), rest::binary>>) do
    {:ok, <<lower7bits::bitstring, progress::bitstring>>, rest}
  end

  defp do_scan(_progress, <<1::1, _lower7bits::bitstring-size(7), rest::binary>>) when rest === <<>> do
    {:error, :no_rest_binary_found}
  end

  defp do_scan(progress, <<1::1, lower7bits::bitstring-size(7), rest::binary>>) do
    do_scan(<<lower7bits::bitstring, progress::bitstring>>, rest)
  end
end
