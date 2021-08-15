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
CACHE_DIR = $(abspath ./.make_cache)
OUTPUT = $(MIX_APP_PATH)/priv

SKETCH_NAME = $(shell basename $(SKETCH))
BUILD_PATH = $(SKETCH)/build/$(subst :,.,$(FQBN))
BIN_FILE = $(SKETCH_NAME).ino.bin

SKETCH_FILES  = $(wildcard $(SKETCH)/*.ino)
SKETCH_FILES += $(wildcard $(SKETCH)/*.h)
SKETCH_FILES += $(wildcard $(SKETCH)/*.cpp)
SKETCH_FILES += $(wildcard $(SKETCH)/*.c)


# if the TARGET_* variables are set, download the bossac executable, else skip
ifneq ($(TARGET_ARCH)$(TARGET_OS)$(TARGET_ABI),)

BOSSAC_DOWNLOAD_URL = https://github.com/shumatech/BOSSA/releases/download/1.7.0/bossac-1.7.0-$(TARGET_ARCH)-$(TARGET_OS)-$(TARGET_ABI).tar.gz
all: requirements compile download-bossac
.PHONY: all

else

$(warning "Skipping bossac download because TARGET_* variables are not set. \
  If you are compiling the nerves firmware this will make the program crash at \
  runtime, otherwise its probably be fine.")
all: requirements compile
.PHONY: all

endif


compile: $(OUTPUT)/$(BIN_FILE)
.PHONY: compile

$(OUTPUT)/$(BIN_FILE): $(SKETCH_FILES)
	arduino-cli compile $(SKETCH) --fqbn $(FQBN) --export-binaries
	mkdir -p $(OUTPUT)
	cp $(BUILD_PATH)/$(BIN_FILE) $@


download-bossac: $(OUTPUT)/bossac
.PHONY: download-bossac

$(OUTPUT)/bossac: $(CACHE_DIR)/downloads/bossac $(OUTPUT)/.noscrub
	mkdir -p $(OUTPUT)
	cp $< $@

# The --strip-components=1 flag removes the folder inside the .tar.gz archive,
#   this way onyly the bossac executable gets extracted
$(CACHE_DIR)/downloads/bossac:
	mkdir -p $(CACHE_DIR)/downloads
	wget -c $(BOSSAC_DOWNLOAD_URL) -O - | tar -xz --strip-components=1 -C $(CACHE_DIR)/downloads

# The .noscrub file is need to make nerves stop complaining about the
#   fact that bossac is not compiled for the target architecture,
#   even though IT IS
$(OUTPUT)/.noscrub:
	touch $@


requirements: $(CACHE_DIR)/.requirements
.PHONY: requirements

$(CACHE_DIR)/.requirements: $(SKETCH)/requirements.txt
	mkdir -p $(CACHE_DIR)
	echo "this file is just a placeholder to ensure that make does not run this recipe every single time" > $@
	xargs -n 1 arduino-cli lib install < $<


clean:
	rm -rf $(DOWNLOAD_CACHE_DIR) $(BUILD_PATH) $(OUTPUT)
.PHONY: clean
