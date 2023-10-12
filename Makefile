# Copyright 2023 SECO Mind Srl
# SPDX-License-Identifier: Apache-2.0

# This Makefile serves to generate language-specific messages from .proto file.

# we want bash as shell
SHELL := $(shell if [ -x "$$BASH" ]; then echo $$BASH; \
	else if [ -x BASH_PATH="$(command -v bash)" ]; then echo $$BASH_PATH; \
	else echo sh; fi; fi)

# Set O variable if not already done on the command line;
# or avoid confusing packages that can use the O=<dir> syntax for out-of-tree
# build by preventing it from being forwarded to sub-make calls.
ifneq ("$(origin O)", "command line")
O := $(CURDIR)/output
endif

# Remove the trailing '/.' from $(O) as it can be added by the makefile wrapper
# installed in the $(O) directory.
# Also remove the trailing '/' the user can set when on the command line.
override O := $(patsubst %/,%,$(patsubst %.,%,$(O)))
# Make sure $(O) actually exists before calling realpath on it; this is to
# avoid empty CANONICAL_O in case on non-existing entry.
CANONICAL_O := $(shell mkdir -p $(O) >/dev/null 2>&1)$(realpath $(O))

CANONICAL_CURDIR = $(realpath $(CURDIR))

PROTO_DIR = $(CANONICAL_CURDIR)/proto
RUST_LANG_DIR = $(CANONICAL_CURDIR)/rust
ELIXIR_LANG_DIR = $(CANONICAL_CURDIR)/elixir
ELIXIR_LANG_LIB=$(ELIXIR_LANG_DIR)/edgehog_device_forwarder_proto/lib/edgehog_device_forwarder_proto

BASE_DIR := $(CANONICAL_O)
$(if $(BASE_DIR),, $(error output directory "$(O)" does not exist))

BUILD_DIR := $(BASE_DIR)/build
RUST_BUILD_DIR := $(BUILD_DIR)/rust
ELIXIR_BUILD_DIR := $(BUILD_DIR)/elixir

FILES=$(wildcard $(PROTO_DIR)/edgehog/device/forwarder/*.proto)

PROTOC_CHECK_SCRIPT=$(CANONICAL_CURDIR)/scripts/protoc_check.sh
ELIXIR_DEPS_CHECK_SCRIPT=$(CANONICAL_CURDIR)/scripts/elixir_deps_check.sh

RUST_LANG=$(RUST_BUILD_DIR)/proto.rs
RUST_FILES=$(shell find "$(RUST_LANG_DIR)/rust-codegen" -type f -regex '.*(rs|Cargo.toml|Cargo.lock)$$') \
	$(RUST_LANG_DIR)/Cargo.toml $(RUST_LANG_DIR)/Cargo.lock

ELIXIR_LANG=$(ELIXIR_BUILD_DIR)/edgehog/device/forwarder/http.pb.ex \
	$(ELIXIR_BUILD_DIR)/edgehog/device/forwarder/ws.pb.ex \
	$(ELIXIR_BUILD_DIR)/edgehog/device/forwarder/message.pb.ex
ELIXIR_FILES="$(ELIXIR_LANG_LIB)/edgehog/device/forwarder/"{http,ws,message}.pb.ex

# This is our default rule, so must come first
.PHONY: all
all: rust elixir

.PHONY: install
install: rust-install elixir-install

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: protoc-check
protoc-check: $(PROTOC_CHECK_SCRIPT)
	$(PROTOC_CHECK_SCRIPT)

.PHONY: rust
rust: protoc-check $(RUST_LANG)

$(RUST_LANG): $(FILES) $(RUST_FILES)
	cargo run --manifest-path "$(RUST_LANG_DIR)"/Cargo.toml -p rust-codegen -- -w "$(PROTO_DIR)" -o "$(RUST_BUILD_DIR)"

.PHONY: rust-install
rust-install: rust
	install -m 664 "$(RUST_BUILD_DIR)/edgehog.device.forwarder.rs" "$(RUST_LANG_DIR)/edgehog-device-forwarder-proto/src/proto.rs"

.PHONY: rust-dirclean
rust-dirclean:
	rm -rf $(RUST_BUILD_DIR)

$(ELIXIR_LANG) &: $(FILES)
	mkdir -p $(ELIXIR_BUILD_DIR)
	protoc \
	  --elixir_out=$(ELIXIR_BUILD_DIR) \
	  --elixir_opt=package_prefix=EdgehogDeviceForwarderProto \
	  --proto_path=$(PROTO_DIR) \
	  $(FILES)
	mix format $(ELIXIR_LANG)

elixir-dependencies-check: $(ELIXIR_DEPS_CHECK_SCRIPT)
	$(SHELL) $(ELIXIR_DEPS_CHECK_SCRIPT)

.PHONY: elixir
elixir: protoc-check elixir-dependencies-check $(ELIXIR_LANG)

.PHONY: elixir-install
elixir-install: elixir
	mkdir -p "$(ELIXIR_LANG_LIB)/edgehog/device/forwarder/"
	install -m 644 $(ELIXIR_LANG) "$(ELIXIR_LANG_LIB)/edgehog/device/forwarder/"

.PHONY: elixir-dirclean
elixir-dirclean:
	rm -rf $(ELIXIR_BUILD_DIR)

.PHONY: help
help:
	@echo 'Cleaning:'
	@echo '  clean                  - Delete all files created by build'
	@echo
	@echo 'Build:'
	@echo '  all                    - Build everything and generate the code for the various languages'
	@echo '  install                - Install files into repo folder'
	@echo
	@echo 'Language-specific:'
	@echo '  <lang>                 - Build and generate the code for the <lang> languages'
	@echo '  <lang>-install         - Install <lang> files into the repo <lang> folder'
	@echo '  <lang>-dirclean        - Remove <lang> build directory'
