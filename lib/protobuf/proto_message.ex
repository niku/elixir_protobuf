defmodule Protobuf.ProtoMessage do
  @moduledoc false

  def new(_type) do
    %{}
  end

  def update(proto_messsage, key_no, value) do
    Map.put(proto_messsage, key_no, value)
  end

  def get_type(_proto_message_type, _key_no) do
    {:ok, :int32}
  end
end
