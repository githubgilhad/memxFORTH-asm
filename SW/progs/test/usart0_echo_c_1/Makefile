BUILD ?= build-mega-atmega2560
CC = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump

LIB_PREFIX = ../../../libs

Ilibs = -I$(LIB_PREFIX)

CFLAGS=-Os -mmcu=atmega2560 -std=gnu99 -ffreestanding -fno-exceptions -fno-unwind-tables -nostdlib $(Ilibs)
ASFLAGS=-mmcu=atmega2560
LDFLAGS=-Wl,-Ttext=0

SRC ?=  $(notdir $(CURDIR)).S
TARGET := $(notdir $(CURDIR))

OBJS=\
	$(LIB_PREFIX)/Serial/usart0/$(BUILD)/usart0.o \
	$(LIB_PREFIX)/isr_stub/$(BUILD)/isr_stub.o \
	$(LIB_PREFIX)/vectors_table/$(BUILD)/vectors_table.o \
	$(BUILD)/reset.o \
	$(BUILD)/$(TARGET).o

all: $(BUILD)/$(TARGET).hex $(TARGET).dis | $(BUILD)/

%/:
	mkdir -p $@

$(BUILD)/$(TARGET).elf: $(OBJS) | $(BUILD)/
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS)

$(BUILD)/%.o: %.c  | $(BUILD)/
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/%.o: %.S  | $(BUILD)/
	$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD)/$(TARGET).hex: $(BUILD)/$(TARGET).elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@

$(TARGET).dis: $(BUILD)/$(TARGET).elf Makefile
	$(OBJDUMP) --disassemble --source --line-numbers --demangle -z --section=.text  --section=.data --section=.bss $< > $@

upload: $(BUILD)/$(TARGET).hex
	/usr/bin/avrdude -v -V -p atmega2560 -D -c wiring -b 115200 -P /dev/ttyACM0 -U flash:w:$<:i

monitor:
	picocom -b 115200 --flow n --noreset --quiet /dev/ttyACM0

upload_monitor: upload monitor

clean:
	rm -f *.o *.elf *.hex *.dis 
	rm -rf $(BUILD)
