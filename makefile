# Comment out following line to debug makefile. The debug rule is at the bottom of this file
#DEBUG := "Epstein didn't kill himself"

# Options
#QUIET := @ # supress echo from rules
SOURCE_DIR := src/
BUILD_DIR := build/
HEADERS_DIR := $(SOURCE_DIR)headers
SRC_FILES := $(foreach sdir,$(SOURCE_DIR),$(wildcard $(sdir)*.c)) # for each item in SOURCE_DIR that ends with .c save to SRC_FILES
OBJ_FILES = $(subst $(SOURCE_DIR),$(BUILD_DIR),$(SRC_FILES:.c=.o)) # for each item in SRC_FILES replace .c with .o and save to OBJ_FILES
HEADER_FILES = $(foreach sdir,$(SOURCE_DIR)$(HEADERS_DIR),$(wildcard $(sdir)*.h)) # for each item in SOURCE_DIR/HEADERS_DIR that ends with .h save to HEADER_FILES


ifdef DEBUG
.DEFAULT_GOAL := debug
else
.DEFAULT_GOAL := $(BUILD_DIR)output.hex
endif


# Vendor
SYSTEM_BASE := vendor/build_system/
LINKER_SCRIPT := $(SYSTEM_BASE)linker_script.ld
VENDOR_SOURCE := $(foreach sdir,$(SYSTEM_BASE),$(wildcard $(sdir)*.c)) # grab all c source from vendor
VENDOR_SOURCE += $(foreach sdir,$(SYSTEM_BASE),$(wildcard $(sdir)*.S)) # grab all S source from vendor and append to VENDOR_SOURCE
VENDOR_OBJECTS := $(VENDOR_SOURCE:.S=.o) # for each item in VENDOR_SOURCE copy to VENDOR_OBJECTS and replace .S with .o
VENDOR_OBJECTS := $(VENDOR_OBJECTS:.c=.o) # for each item in VENDOR_OBJECT replace .c with .o
VENDOR_OBJECTS := $(subst $(SYSTEM_BASE),$(BUILD_DIR),$(VENDOR_OBJECTS)) # for each item in VENDOR_OBJECTS rename SYSTEM_BASE to BUILD_DIR

# Makefile options
.VPATH = $(BUILD_DIR) $(SYSTEM_BASE) $(SOURCE_DIR) # where to look for prerequisites and targets

# Compiler
CC := arm-none-eabi-gcc
OBJCOPY := arm-none-eabi-objcopy

# Linker and Compiler options
CFLAGS := -Wall -std=c11 -Werror
CFLAGS += -I$(HEADERS_DIR)
CFLAGS += -mcpu=cortex-m0 -mthumb -mabi=aapcs -mfloat-abi=soft # CPU Specific compiler flags
CFLAGS += -ffunction-sections -fdata-sections --short-enums -fno-strict-aliasing -fno-builtin # Free linker optimizations
LDFLAGS := --specs=nosys.specs -Wl,--gc-sections -T $(LINKER_SCRIPT)


# Rules

# Rule 1. Create a build directory
$(BUILD_DIR) :
	$(QUIET) mkdir -p $@


# Rule 2. Generate pre-main magic code.
$(VENDOR_OBJECTS) : $(VENDOR_SOURCE)
	$(QUIET) $(CC) $(CFLAGS) -I$(SYSTEM_BASE) -c $< -o $@


# Rule 3. Generate object file out of users c -files
$(OBJ_FILES) : $(SRC_FILES) $(BUILD_DIR) $(VENDOR_OBJECTS)
	$(QUIET) $(CC) $(CFLAGS) -c $< -o $@


# Rule 4. link object files together
$(BUILD_DIR)output.elf : $(OBJ_FILES) $(VENDOR_OBJECTS)
	$(QUIET) $(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@


# Rule 5. convert binary into hex file
.PHONY: compile
$(BUILD_DIR)output.hex : $(BUILD_DIR)output.elf
	$(QUIET) $(OBJCOPY) -O ihex $(BUILD_DIR)output.elf $@


# Rule 6. upload binary
.PHONY: flash
flash : $(BUILD_DIR)output.hex
	$(QUIET) nrfjprog -f nrf51 --chiperase --program $<
	$(QUIET) nrfjprog -f nrf51 --reset


# Rule 7. clear content on the chip
.PHONY: erase
erase :
	$(QUIET) nrfjprog -f nrf51 --eraseall


# Rule 8. Clean repository for build files.
.PHONY: clean
clean :
	$(QUIET) rm -rf $(BUILD_DIR)


# Formating rules
.PHONY: format
format: $(SRC_FILES) $(HEADER_FILES)
	$(QUIET) indent --linux-style --line-length0 $(SRC_FILES) $(HEADER_FILES)
	$(QUIET) rm -rf $(SOURCE_DIR)*.c~ $(HEADERS_DIR)*.h~


# Help rule
.PHONY: help
help:
	@echo "Available rules:"
	@echo "make build: compile all sources (default goal)"
	@echo "make format: format all source code"
	@echo "make connect: connect picocom monitor to target (not implemented)"
	@echo "make gdb: connect gdb to target (not implemented)" 
	@echo "make clean: clean the repository for compiled files"
	@echo "make erase: erase the target"


# Debugging rule
.PHONY: debug
debug:
	@echo $(SRC_FILES)
