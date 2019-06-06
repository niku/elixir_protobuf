defmodule Protobuf.Parser do
  @moduledoc false

  alias Protobuf.Parser.Key
  alias Protobuf.Parser.Value
  alias Protobuf.ProtoMessage

  def parse(binary, proto_message_type) when is_binary(binary) do
    do_parse(binary, proto_message_type.new(), proto_message_type)
  end

  defp do_parse(<<>>, proto_message, _proto_message_type) do
    {:ok, proto_message}
  end

  defp do_parse(binary, proto_message, proto_message_type) do
    {:ok, key_no, wire_type_no, rest} = Key.parse(binary)
    {:ok, value_type} = proto_message_type.get_value_type(key_no)
    {:ok, value, rest2} = Value.parse(rest, wire_type_no, value_type)
    do_parse(rest2, proto_message_type.update(proto_message, key_no, value), proto_message_type)
  end
end
