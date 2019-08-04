defmodule ProtobufTest do
  use ExUnit.Case, async: true
  doctest Protobuf

  alias Protobuf.Adapter

  describe "decode/1" do
    setup %{test: test} do
      message = Module.concat(test, Message)
      adapter = Module.concat(test, Adapter)

      defmodule message do
        use Ecto.Schema

        @primary_key false

        embedded_schema do
          field(:my_int_field, Protobuf.Types.Int32, default: 0, source: 1)
        end
      end

      Adapter.define(adapter, message: message)
      %{message: message, adapter: adapter}
    end

    test "decodes binary to struct", %{message: message, adapter: adapter} do
      assert {:ok, struct!(message, my_int_field: 150)} == Protobuf.decode(adapter, :binary.encode_unsigned(0x08_96_01))
    end
  end
end
