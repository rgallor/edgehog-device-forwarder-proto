# Copyright 2023 SECO Mind Srl
# SPDX-License-Identifier: Apache-2.0

defmodule EdgehogDeviceForwarderProtoTest do
  use ExUnit.Case
  alias EdgehogDeviceForwarderProto.Edgehog.Device.Forwarder.{Message, Http, WebSocket}
  doctest EdgehogDeviceForwarderProto

  test "encode and decode test" do
    ws = %WebSocket{socket_id: <<>>, message: {:text, "some string"}}
    assert ws == ws |> WebSocket.encode() |> WebSocket.decode()

    http_response = %Http.Response{status_code: 200, headers: %{}, body: <<>>}
    http = %Http{request_id: <<>>, message: {:response, http_response}}

    assert http == http |> Http.encode() |> Http.decode()

    message = %Message{protocol: {:ws, ws}}
    assert message == message |> Message.encode() |> Message.decode()
    assert {:ws, ^ws} = message |> Message.encode() |> Message.decode() |> Map.get(:protocol)
  end
end
