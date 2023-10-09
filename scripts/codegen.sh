#! /usr/bin/env bash

# Copyright 2023 SECO Mind Srl
# SPDX-License-Identifier: Apache-2.0

set -exEuo pipefail

PROTOC_VERSION='24.3'
version=$(protoc --version | cut -d ' ' -f 2)

if [[ $version != $PROTOC_VERSION ]]; then
    echo "incompatible protoc version $version, expected $PROTOC_VERSION" >&2
    exit 1
fi

cargo run --manifest-path rust/Cargo.toml -p rust-codegen -- -w proto -o out
mv -v out/edgehog.device.forwarder.rs rust/edgehog-device-forwarder-proto/src/proto.rs
