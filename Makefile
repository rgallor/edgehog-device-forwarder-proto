.PHONY=clean

FILES=$(wildcard proto/edgehog/device/forwarder/*.proto)
OUTPUT=rust/edgehog-device-forwarder-proto/src/proto.rs
CODEGEN_SCRIPT=./scripts/codegen.sh

$(OUTPUT): $(FILES) $(CODEGEN_SCRIPT)
	$(CODEGEN_SCRIPT)

clean:
	rm -vr out/
