#!/usr/bin/env bash

# Copyright 2023 SECO Mind Srl
# SPDX-License-Identifier: Apache-2.0

set -eu

PROTOC_GEN_ELIXIR_VERSION="0.12.0"
version=$(protoc-gen-elixir --version)

if [ "$version" != "$PROTOC_GEN_ELIXIR_VERSION" ]; then
    echo "incompatible elixir-protobuf version: found \"$version\", \
expected \"$PROTOC_GEN_ELIXIR_VERSION\"" >&2
    exit 1
fi
