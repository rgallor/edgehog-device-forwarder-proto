#! /usr/bin/env bash

# Copyright 2023 SECO Mind Srl
# SPDX-License-Identifier: Apache-2.0

set -exEuo pipefail

if ! DIFF=$(git diff --exit-code)
then
    echo "differences between the generated files" >&2
    echo "$DIFF"
    exit 1
fi
