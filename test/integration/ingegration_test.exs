defmodule Protobuf.IntegrationTest do
  use ExUnit.Case, async: true

  describe "int32" do
    current_dir = Path.dirname(Path.absname(__ENV__.file))

    json =
      File.read!(Path.join(current_dir, "int32_test.json"))
      |> Jason.decode!()
      |> Enum.map(fn {k, v} ->
        {String.to_integer(k), Base.decode64!(v)}
      end)
      |> Enum.into(Map.new())

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

      Protobuf.Adapter.define(adapter, message: message)
      %{message: message, adapter: adapter}
    end

    Enum.each(json, fn {expected_value, pb_message} ->
      test "#{expected_value}", %{message: message, adapter: adapter} do
        assert {:ok, struct!(message, my_int_field: unquote(expected_value))} ==
                 Protobuf.decode(adapter, unquote(pb_message))
      end
    end)
  end

  describe "string" do
    current_dir = Path.dirname(Path.absname(__ENV__.file))

    json =
      File.read!(Path.join(current_dir, "string_test.json"))
      |> Jason.decode!()
      |> Enum.map(fn {k, v} ->
        {k, Base.decode64!(v)}
      end)
      |> Enum.into(Map.new())

    setup %{test: test} do
      message = Module.concat(test, Message)
      adapter = Module.concat(test, Adapter)

      defmodule message do
        use Ecto.Schema

        @primary_key false

        embedded_schema do
          field(:my_string_field, Protobuf.Types.String, default: "", source: 1)
        end
      end

      Protobuf.Adapter.define(adapter, message: message)
      %{message: message, adapter: adapter}
    end

    Enum.each(json, fn {expected_value, pb_message} ->
      test "#{expected_value}", %{message: message, adapter: adapter} do
        assert {:ok, struct!(message, my_string_field: unquote(expected_value))} ==
                 Protobuf.decode(adapter, unquote(pb_message))
      end
    end)
  end
end
