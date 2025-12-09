BUILD ?= build-mega-atmega2560

MCU ?= atmega2560
CC = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump

CFLAGS ?= -mmcu=$(MCU) -Wall -Os -nostartfiles

TARGET := $(notdir $(CURDIR))

.PHONY: all clean upload

all: $(BUILD)/$(TARGET).o $(BUILD)/$(TARGET).dis| $(BUILD)/ 

$(BUILD)/:
	mkdir -p $(BUILD)/


$(BUILD)/%.o: %.S  | $(BUILD)/
	$(CC) $(CFLAGS) -c $< -o $@
	-$(OBJCOPY) -O binary $@ $@.bin

$(BUILD)/$(TARGET).dis: $(BUILD)/$(TARGET).o Makefile
	$(OBJDUMP) --disassemble --source --line-numbers --demangle -z --section=.text  --section=.data --section=.bss $< > $@

clean:
	rm -f *.o *.elf *.hex *.dis 
	rm -rf $(BUILD)
