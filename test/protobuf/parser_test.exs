defmodule Protobuf.ParserTest do
  use ExUnit.Case, async: true
  import BitsSigils

  alias Protobuf.Parser

  defmodule MyMessage do
    @moduledoc false
    use Ecto.Schema

    @primary_key false

    embedded_schema do
      field(:my_int_field, :integer, default: 0, source: 1)
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

      Map.fetch(source, key_no)
    end

    def update(proto_message, _key_no, value) do
      Map.put(proto_message, :my_int_field, value)
    end
  end

  test "Protobuf.Parser.parse(00001000_10010110_00000001, proto) returns {:ok, %{1 => 150}}" do
    assert {:ok, %MyMessage{my_int_field: 150}} = Parser.parse(~b(00001000_10010110_00000001), MyMessage)
  end
end
