defmodule Protobuf.IntegrationTest do
  use ExUnit.Case, async: true

  describe "int32" do
    defmodule Main.Int32Test do
      use Ecto.Schema

      @primary_key false

      embedded_schema do
        field(:value, :integer, default: 0, source: 1)
      end
    end

    current_dir = Path.dirname(Path.absname(__ENV__.file))

    json =
      File.read!(Path.join(current_dir, "int32_test.json"))
      |> Jason.decode!()
      |> Enum.map(fn {k, v} ->
        {String.to_integer(k), Base.decode64!(v)}
      end)
      |> Enum.into(Map.new())

    Enum.each(json, fn {expected_value, pb_message} ->
      test "#{expected_value}" do
        assert %__MODULE__.Main.Int32Test{value: unquote(expected_value)} ==
                 Protobuf.decode!(__MODULE__.Main.Int32Test, unquote(pb_message))
      end
    end)
  end

  describe "string" do
    defmodule Main.StringTest do
      use Ecto.Schema

      @primary_key false

      embedded_schema do
        field(:value, :string, default: 0, source: 1)
      end
    end

    current_dir = Path.dirname(Path.absname(__ENV__.file))

    json =
      File.read!(Path.join(current_dir, "string_test.json"))
      |> Jason.decode!()
      |> Enum.map(fn {k, v} ->
        {k, Base.decode64!(v)}
      end)
      |> Enum.into(Map.new())

    Enum.each(json, fn {expected_value, pb_message} ->
      test "#{expected_value}" do
        assert %__MODULE__.Main.StringTest{value: unquote(expected_value)} ==
                 Protobuf.decode!(__MODULE__.Main.StringTest, unquote(pb_message))
      end
    end)
  end
end
