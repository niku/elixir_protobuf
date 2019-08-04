defmodule Protobuf do
  @moduledoc """
  Documentation for Protobuf.
  """

  def decode(adapter, binary) when is_atom(adapter) and is_binary(binary) do
    apply(adapter, :decode, [binary])
  end
end
