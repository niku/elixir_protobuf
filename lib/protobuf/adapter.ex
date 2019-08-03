defmodule Protobuf.Adapter do
  @callback encode(message :: Ecto.Schema.t()) :: binary() | :error
  @callback decode(binary :: binary()) :: Ecto.Schema.t() | :error

  def build_source(message) do
    for field <- message.__schema__(:fields), into: Map.new() do
      {message.__schema__(:field_source, field), {field, message.__schema__(:type, field)}}
    end
  end

  def define(module, options) do
    defmodule module do
      @behaviour Protobuf.Adapter
      @message Keyword.get(options, :message)
      @source Protobuf.Adapter.build_source(@message)

      alias Ecto.Type
      alias Protobuf.Decoder

      @impl Protobuf.Adapter
      def encode(%@message{} = message) do
      end

      @impl Protobuf.Adapter
      def decode(binary) when is_binary(binary) do
        {:ok, map} = Decoder.decode(binary)

        fields =
          for {key_no, raw_value} <- map, into: [] do
            {field_name, field_type} = @source[key_no]
            {:ok, loaded_value} = Type.load(field_type, raw_value)
            {field_name, loaded_value}
          end

        {:ok, struct!(@message, fields)}
      end
    end
  end
end
