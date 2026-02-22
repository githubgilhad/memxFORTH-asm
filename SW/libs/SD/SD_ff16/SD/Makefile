BUILD ?= build-mega-atmega2560

MCU ?= atmega2560
CC = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump



MAKEFLAGS += --no-print-directory --no-builtin-rules


CFLAGS = -Os -mmcu=$(MCU) -std=gnu99 -Wall -ffreestanding -fno-exceptions -fno-unwind-tables  -DF_CPU=16000000UL
#	-nostartfiles	Bez standardního vstupního kódu (crt0.o)
#	-ffreestanding	Nepředpokládat přítomnost libc, vlastní prostředí
#	-fno-exceptions	Zakáže C++ výjimky
#	-fno-unwind-tables	Zakáže metadata pro stack trace (např. s výjimkami, laděním)
ASFLAGS = -mmcu=$(MCU)
# LDFLAGS = -Wl,-Ttext=0



PORT ?=  $(firstword $(wildcard /dev/ttyA-* /dev/ttyAr* /dev/ttyTot* /dev/ttyUSB* /dev/ttyACM* /dev/null) )
# TARGET := $(notdir $(CURDIR))
TARGET = test
OBJ_SOURCES = $(wildcard *.c)
OBJS := $(patsubst %.c,$(BUILD)/%.o,$(OBJ_SOURCES)) ../../../Serial.RTS/usart0/build-mega-atmega2560/usart0.o
.PHONY: all clean upload

all:  $(BUILD)/$(TARGET).hex  $(TARGET).dis | $(BUILD)/ 

%/:
	mkdir -p $@

$(BUILD)/$(TARGET).elf: $(OBJS) | $(BUILD)/
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^


$(BUILD)/$(TARGET).hex: $(BUILD)/$(TARGET).elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@


$(BUILD)/%.o: %.c  | $(BUILD)/
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/%.o: %.S  | $(BUILD)/
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f *.o *.elf *.hex *.dis 
	rm -rf $(BUILD)



sizecheck: $(BUILD)/$(TARGET).elf
	@avr-size  -A $(BUILD)/$(TARGET).elf | awk '/text/ {if($$2 > 262144) { \
		printf "Program too big: 256 kB FLASH <  %d bytes\n", $$2; \
			exit 1 \
		} else { \
			printf "Program size OK: %d bytes\n", $$2 \
		} \
	}'
	@avr-size $(BUILD)/$(TARGET).elf $(BUILD)/$(TARGET).hex |myavrsize.py 


$(TARGET).dis: $(BUILD)/$(TARGET).elf Makefile
	@# $(OBJDUMP) --disassemble --source --line-numbers --demangle -z --section=.text  --section=.data --section=.bss  --section=.rodata --section=.FORTH $< > $@
	$(OBJDUMP)   --disassemble --source --line-numbers --demangle -z --section=.text  --section=.data --section=.bss  --section=.rodata --section=.FORTH_data $< > $@
	@if ( $(OBJDUMP) -h $< | grep -q "\.FORTH_data") ; then \
		$(OBJDUMP) -s -j .FORTH_data  $< >> $@ ; \
	fi
	@# $(OBJDUMP)  --disassemble --source --line-numbers --demangle -z --section=.FORTH_data $< >> $@
	@Elf.rb $(BUILD)/$(TARGET).elf $(BUILD)/$(TARGET).bin2 $(BUILD)/$(TARGET).xref2
	@AVRemu -d -m $(MCU)  -x $(BUILD)/$(TARGET).xref2 $(BUILD)/$(TARGET).bin2 >$(BUILD)/$(TARGET).dis2 || true

upload: $(BUILD)/$(TARGET).hex reset sizecheck
	/usr/bin/avrdude -v -V -p $(MCU) -D -c wiring -b 115200 -P $(PORT) -U flash:w:$<:i

ispload: $(BUILD)/$(TARGET).hex sizecheck 
	/usr/bin/avrdude -v -p atmega2560 -c usbasp -b 115200 -e -U lock:w:0x3F:m -U efuse:w:0xFD:m -U hfuse:w:0xD1:m -U lfuse:w:0xBF:m
	/usr/bin/avrdude -v -p $(MCU) -D -c usbasp -b 115200                 -U flash:w:$<:i

bootloader:
	/usr/bin/avrdude -v -p atmega2560 -c usbasp -b 115200 -e -U lock:w:0x3F:m -U efuse:w:0xFD:m -U hfuse:w:0xD0:m -U lfuse:w:0xBF:m
	/usr/bin/avrdude -v -p atmega2560 -c usbasp -b 115200 -U flash:w:/usr/share/arduino/hardware/arduino/avr/bootloaders//stk500v2/stk500boot_v2_mega2560.hex:i

reset:
	if [ -x $(dir $(realpath $(lastword $(MAKEFILE_LIST))))ard-reset-arduino ] ; then $(dir $(realpath $(lastword $(MAKEFILE_LIST))))ard-reset-arduino  $(PORT); fi

TODO:
	@grep  --color=always -r "TODO\|FIXME"

WORDS:
	@find -name "*.S" -exec grep -h "^DEF" {} \;|sort>WORDS.list

monitor:
	picocom -b 115200 --flow h --noreset --quiet $(PORT)

upload_monitor: upload monitor

