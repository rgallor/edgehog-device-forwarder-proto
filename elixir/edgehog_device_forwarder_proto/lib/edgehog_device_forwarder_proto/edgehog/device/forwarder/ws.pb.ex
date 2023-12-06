defmodule EdgehogDeviceForwarderProto.Edgehog.Device.Forwarder.WebSocket.Close do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field(:code, 1, type: :uint32)
  field(:reason, 2, type: :string)
end

defmodule EdgehogDeviceForwarderProto.Edgehog.Device.Forwarder.WebSocket do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  oneof(:message, 0)

  field(:socket_id, 1, type: :bytes, json_name: "socketId")
  field(:text, 2, type: :string, oneof: 0)
  field(:binary, 3, type: :bytes, oneof: 0)
  field(:ping, 4, type: :bytes, oneof: 0)
  field(:pong, 5, type: :bytes, oneof: 0)

  field(:close, 6,
    type: EdgehogDeviceForwarderProto.Edgehog.Device.Forwarder.WebSocket.Close,
    oneof: 0
  )
end
