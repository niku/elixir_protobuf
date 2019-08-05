defmodule Protobuf.IntegrationTest do
  use ExUnit.Case, async: true

  @read_json fn path ->
    __ENV__.file
    |> Path.absname()
    |> Path.dirname()
    |> Path.join(path)
    |> File.read!()
    |> Jason.decode!()
    |> Enum.map(fn {k, v} ->
      {k, Map.update!(v, "encoded", &Base.decode64!/1)}
    end)
  end

  describe "int32" do
    setup %{test: test} do
      message = Module.concat(test, Message)
      adapter = Module.concat(test, Adapter)

      defmodule message do
        use Ecto.Schema

        @primary_key false

        embedded_schema do
          field(:a_field, Protobuf.Types.Int32, default: 0, source: 1)
        end
      end

      Protobuf.Adapter.define(adapter, message: message)
      %{message: message, adapter: adapter}
    end

    for {describe, %{"decoded" => decoded, "encoded" => encoded}} <- @read_json.("int32_test.json") do
      test describe, %{message: message, adapter: adapter} do
        assert {:ok, struct!(message, a_field: unquote(decoded))} == Protobuf.decode(adapter, unquote(encoded))
      end
    end
  end

  describe "string" do
    setup %{test: test} do
      message = Module.concat(test, Message)
      adapter = Module.concat(test, Adapter)

      defmodule message do
        use Ecto.Schema

        @primary_key false

        embedded_schema do
          field(:a_field, Protobuf.Types.String, default: "", source: 1)
        end
      end

      Protobuf.Adapter.define(adapter, message: message)
      %{message: message, adapter: adapter}
    end

    for {describe, %{"decoded" => decoded, "encoded" => encoded}} <- @read_json.("string_test.json") do
      test describe, %{message: message, adapter: adapter} do
        assert {:ok, struct!(message, a_field: unquote(decoded))} == Protobuf.decode(adapter, unquote(encoded))
      end
    end
  end
end
