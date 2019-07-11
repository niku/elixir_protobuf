defmodule Protobuf.DecoderTest do
  use ExUnit.Case, async: true
  import BitsSigils

  alias Protobuf.Decoder

  defmodule MyMessage do
    @moduledoc false
    use Ecto.Schema

    @primary_key false

    embedded_schema do
      field(:my_int_field, Protobuf.Types.Int32, default: 0, source: 1)
    end

    def new do
      %__MODULE__{}
    end

    def get_value_type(key_no) when is_integer(key_no) do
      # TODO Inline
      source =
        for field <- __schema__(:fields), into: Map.new() do
          {__schema__(:field_source, field), {field, __schema__(:type, field)}}
        end

      {_field_name, field_type} = Map.get(source, key_no)
      {:ok, field_type}
    end

    def update(proto_message, _key_no, value) do
      Map.put(proto_message, :my_int_field, value)
    end
  end

  test "Protobuf.Decoder.parse(00001000_10010110_00000001) returns {:ok, %{1 => 150}}" do
    assert {:ok, %{1 => 150}} = Decoder.parse(~b(00001000_10010110_00000001))
  end
end
