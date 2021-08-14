# This makefile will compile the arduino sketch and include the compiled .bin
# file int the nerves firmware.
# The .bin file will be placed in the priv/ directory of the :braccino_firmware
# application.
#
# Environment variables:
# - MIX_APP_PATH: application path inside the _build folder, the application
#                 being :braccino_firmware

FQBN = arduino:sam:arduino_due_x_dbg
SKETCH = $(abspath ./arduino-sketch)
OUTPUT = $(MIX_APP_PATH)/priv

SKETCH_NAME = $(shell basename $(SKETCH))
BUILD_PATH = $(SKETCH)/build/$(subst :,.,$(FQBN))
BIN_FILE = $(SKETCH_NAME).ino.bin

SKETCH_FILES  = $(wildcard $(SKETCH)/*.ino)
SKETCH_FILES += $(wildcard $(SKETCH)/*.h)
SKETCH_FILES += $(wildcard $(SKETCH)/*.cpp)
SKETCH_FILES += $(wildcard $(SKETCH)/*.c)

all: compile
.PHONY: all

compile: $(OUTPUT)/$(BIN_FILE)
.PHONY: compile

$(OUTPUT)/$(BIN_FILE): $(SKETCH_FILES)
	arduino-cli compile $(SKETCH) --fqbn $(FQBN) --export-binaries
	mkdir -p $(OUTPUT)
	cp $(BUILD_PATH)/$(BIN_FILE) $@

clean:
	rm -rf $(BUILD_PATH) $(OUTPUT)
.PHONY: clean
