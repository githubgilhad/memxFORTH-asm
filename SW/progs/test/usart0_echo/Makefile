BUILD ?= build-mega-atmega2560
# MCU & nástroje
MCU ?= atmega2560
CC = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump

LIB_PREFIX = ../../../libs
Ilibs = -I$(LIB_PREFIX)

CFLAGS = -Os -mmcu=$(MCU) -std=gnu99 -Wall -nostartfiles $(Ilibs)
ASFLAGS = -mmcu=$(MCU)
LDFLAGS = -Wl,-Ttext=0

SRC ?=  $(notdir $(CURDIR)).S
TARGET := $(notdir $(CURDIR))

# ========== Automatická detekce knihoven ==========
# Vyhledá řádky jako: ; LIBS: serial file

# LIB_LINES := $(shell grep -i '^; *LIBS:' $(SRC)|sed "s/; *LIBS://")
# $(info $(foreach line,$(LIB_LINES),### $(line) ###))
# LIBS := $(patsubst %,$(LIB_DIR)/$(BUILD)/%, $(LIB_LINES))
# LIBS_DIRS := $(patsubst %,$(LIB_DIR)/%, $(LIB_LINES))
# LIB_OBJS := $(addsuffix .o, $(LIBS))


LIB_NAMES := $(shell grep -o '^;\s*LIBS:.*' $(SRC) | sed 's/^;\s*LIBS: //' | tr ' ' '\n' | sort -u)
LIB_OBJS := $(foreach lib,$(LIB_NAMES),$(LIB_PREFIX)/$(lib)/$(BUILD)/$(notdir $(lib)).o)

OBJS = $(BUILD)/$(TARGET).o $(LIB_OBJS)

# $(info $(LIB_LINES) ## $(LIBS) ## $(LIB_OBJS) )

# ========== Build pravidla ==========

all: $(BUILD)/$(TARGET).hex $(TARGET).dis | $(BUILD)/

%/:
	mkdir -p $@

$(BUILD)/$(TARGET).elf: $(OBJS) | $(BUILD)/
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
define LIB_RULE_template
$(LIB_PREFIX)/$(1)/$(BUILD)/$(notdir $(1)).o: $(LIB_PREFIX)/$(1)/*
	$(MAKE) -C $(LIB_PREFIX)/$(1) MCU=$(MCU) BUILD=$(BUILD) $(BUILD)/$(notdir $(1)).o
endef

$(BUILD)/%.o: %.c  | $(BUILD)/
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/%.o: %.S  | $(BUILD)/
	$(CC) $(ASFLAGS) -c $< -o $@

$(foreach lib,$(LIB_NAMES),$(eval $(call LIB_RULE_template,$(lib))))

$(BUILD)/$(TARGET).hex: $(BUILD)/$(TARGET).elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@

$(TARGET).dis: $(BUILD)/$(TARGET).elf Makefile
	$(OBJDUMP) --disassemble --source --line-numbers --demangle -z --section=.text  --section=.data --section=.bss $< > $@

upload: $(BUILD)/$(TARGET).hex
	/usr/bin/avrdude -v -V -p $(MCU) -D -c wiring -b 115200 -P /dev/ttyACM0 -U flash:w:$<:i

ispload: $(BUILD)/$(TARGET).hex
	/usr/bin/avrdude -v -p atmega2560 -c usbasp -b 115200 -e -U lock:w:0x3F:m -U efuse:w:0xFD:m -U hfuse:w:0xD9:m -U lfuse:w:0xFF:m
	/usr/bin/avrdude -v -p $(MCU) -D -c usbasp -b 115200                 -U flash:w:$<:i

bootloader:
	/usr/bin/avrdude -v -p atmega2560 -c usbasp -b 115200 -e -U lock:w:0x3F:m -U efuse:w:0xFD:m -U hfuse:w:0xD8:m -U lfuse:w:0xFF:m
	/usr/bin/avrdude -v -p atmega2560 -c usbasp -b 115200 -U flash:w:/usr/share/arduino/hardware/arduino/avr/bootloaders//stk500v2/stk500boot_v2_mega2560.hex:i


monitor:
	picocom -b 115200 --flow n --noreset --quiet /dev/ttyACM0

upload_monitor: upload monitor

clean:
	rm -f *.o *.elf *.hex *.dis 
	rm -rf $(BUILD)
