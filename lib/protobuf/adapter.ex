defmodule Protobuf.Adapter do
  @callback encode(message :: Ecto.Schema.t()) :: binary() | :error
  @callback decode(binary :: binary()) :: Ecto.Schema.t() | :error

  def build_source_field_map(message) do
    for field <- message.__schema__(:fields), into: Map.new() do
      {message.__schema__(:field_source, field), field}
    end
  end

  def define(module, options) do
    defmodule module do
      @behaviour Protobuf.Adapter
      @message Keyword.get(options, :message)
      @source_field_map Protobuf.Adapter.build_source_field_map(@message)

      alias Protobuf.Decoder

      @impl Protobuf.Adapter
      def encode(%@message{} = message) do
      end

      @impl Protobuf.Adapter
      def decode(binary) when is_binary(binary) do
        {:ok, map} = Decoder.parse(binary)
        message = struct!(@message, Enum.map(map, fn {k, v} -> {@source_field_map[k], v} end))
        {:ok, message}
      end
    end
  end
end
