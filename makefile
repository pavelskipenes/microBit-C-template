# Comment out following line to debug makefile. The debug rule is at the bottom of this file
#DEBUG := "Epstein didn't kill himself"

# Options
QUIET := @ # supress echo from rules
TARGET = /dev/ttyACM0
CC := arm-none-eabi-gcc
OBJCOPY := arm-none-eabi-objcopy

# User source options
SOURCE_DIR := src/
BUILD_DIR := build/
VENDOR_DIR := vendor/
HEADERS_DIR := $(SOURCE_DIR)headers/

VENDORS := nrf51/

# Vendor options
BUILD_SYSTEM := $(VENDOR_DIR)nrf51/
LINKER_SCRIPT := $(BUILD_SYSTEM)linker_script.ld


# grab all the source and header files
C_FILES := $(foreach sdir,$(SOURCE_DIR),$(wildcard $(sdir)*.c))
C_FILES += $(foreach sdir,$(BUILD_SYSTEM),$(wildcard $(sdir)*.c))
SRC_FILES = $(C_FILES)
SRC_FILES += $(foreach sdir,$(BUILD_SYSTEM),$(wildcard $(sdir)*.S))
HEADER_FILES = $(foreach sdir,$(HEADERS_DIR),$(wildcard $(sdir)*.h))

# create a list of obj files
OBJ_FILES = $(subst $(SOURCE_DIR),$(BUILD_DIR),$(SRC_FILES:.c=.o))
OBJ_FILES := $(subst $(BUILD_SYSTEM),$(BUILD_DIR),$(OBJ_FILES:.S=.o))

# where to look for prerequisites and targets
.VPATH = $(BUILD_DIR) $(BUILD_SYSTEM) $(SOURCE_DIR)

# Linker and Compiler options
C_FLAGS := -Wall -std=c11 -Werror -g
C_FLAGS += -I$(HEADERS_DIR) -I$(BUILD_SYSTEM) -I$(VENDOR_DIR)
C_FLAGS += -mcpu=cortex-m0 -mthumb -mabi=aapcs -mfloat-abi=soft # CPU Specific compiler flags
C_FLAGS += -ffunction-sections -fdata-sections --short-enums -fno-strict-aliasing -fno-builtin# Free linker optimizations
LD_FLAGS := --specs=nosys.specs -Wl,--gc-sections -T $(LINKER_SCRIPT)


ifdef DEBUG
.DEFAULT_GOAL := debug
else
.DEFAULT_GOAL := $(BUILD_DIR)output.hex
endif


# Rules

# Rule 0: Format code
.PHONY: format
format:
	$(QUIET) indent --linux-style --line-length0 -brf $(C_FILES) $(HEADER_FILES)
	$(QUIET) rm -rf $(SOURCE_DIR)*.c~ $(HEADERS_DIR)*.h~ $(BUILD_SYSTEM)*~


# Rule 1: Create a build directory
$(BUILD_DIR) : format
	$(QUIET) mkdir -p $@


# Rule 2.1: Compile user c source
$(BUILD_DIR)%.o : $(SOURCE_DIR)%.c | $(BUILD_DIR)
	$(QUIET) $(CC) $< $(C_FLAGS) -c -o $@


# Rule 2.2: Compile vendor c files
$(BUILD_DIR)%.o : $(BUILD_SYSTEM)%.c | $(BUILD_DIR)
	$(QUIET) $(CC) $< $(C_FLAGS) -c -o $@


# Rule 2.3: Compile vendor S files
$(BUILD_DIR)%.o : $(BUILD_SYSTEM)%.S | $(BUILD_DIR)
	$(QUIET) $(CC) $< $(C_FLAGS) -c -o $@


# Rule 3: link object files together
$(BUILD_DIR)output.elf : $(OBJ_FILES)
	$(QUIET) $(CC) $(C_FLAGS) $(LD_FLAGS) $^ -o $@


# Rule 4. convert binary into hex file
$(BUILD_DIR)output.hex : $(BUILD_DIR)output.elf
	$(QUIET) $(OBJCOPY) -O ihex $(BUILD_DIR)output.elf $@


# Rule 5. upload binary
.PHONY: flash
flash : $(BUILD_DIR)output.hex
	$(QUIET) nrfjprog -f nrf51 --chiperase --program $<
	$(QUIET) nrfjprog -f nrf51 --reset


# Rule 6: clear content on the chip
.PHONY: erase
erase :
	$(QUIET) nrfjprog -f nrf51 --eraseall


# Rule 7: Clean repository for build files.
.PHONY: clean
clean :
	$(QUIET) rm -rf $(BUILD_DIR) $(SOURCE_DIR)*~ $(BUILD_SYSTEM)*~


.PHONY: connect
connect:
	$(QUIET) picocom $(TARGET)


.PHONY: openocd
openocd:
	$(QUIET) openocd --file=.config/openocd.cfg


# Help rule
.PHONY: help
help:
	@echo "Available rules:"
	@echo "make build: compile all sources (default goal)"
	@echo "make format: format all source code"
	@echo "make connect: connect picocom monitor to target"
	@echo "make clean: clean the repository for compiled files"
	@echo "make erase: erase the target"


.PHONY: debug
debug:
	@echo "CC: " $(CC)
	@echo "VENDORS: " $(VENDORS)
	@echo "VENDOR_DIR: " $(VENDOR_DIR)
	@echo "OBJCOPY: " $(OBJCOPY)
	@echo "LD_FLAGS: " $(LDFLAGS)
	@echo "C_FLAGS: " $(C_FLAGS)
	@echo "TARGET: " $(TARGET)
	@echo "SOURCE_DIR: " $(SOURCE_DIR)
	@echo "BUILD_DIR: " $(BUILD_DIR)
	@echo "HEADERS_DIR: " $(HEADERS_DIR)
	@echo "SRC_FILES: " $(SRC_FILES)
	@echo "OBJ_FILES: " $(OBJ_FILES)
	@echo "HEADER_FILES: " $(HEADER_FILES)
	@echo "BUILD_SYSTEM: " $(BUILD_SYSTEM)
	@echo "LINKER_SCRIPT: " $(LINKER_SCRIPT)
