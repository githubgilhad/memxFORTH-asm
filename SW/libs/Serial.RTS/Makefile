BUILD = build-mega-atmega2560

MCU = atmega2560
CC = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump

CFLAGS = -mmcu=$(MCU) -Wall -Os -nostartfiles

.PHONY: all clean upload

all: $(BUILD)/ $(BUILD)/program.hex program.dis

$(BUILD)/:
	mkdir -p $(BUILD)/

$(BUILD)/program.elf: $(BUILD)/vectors_table.o $(BUILD)/isr_stub.o $(BUILD)/usart0.o $(BUILD)/usart0_echo.o
	$(CC) $(CFLAGS) -o $@ $^

$(BUILD)/%.o: %.S Makefile
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/program.hex: $(BUILD)/program.elf Makefile
	$(OBJCOPY) -O ihex $< $@

program.dis: $(BUILD)/program.elf Makefile
	$(OBJDUMP) --disassemble --source --line-numbers --demangle -z --section=.text  --section=.data --section=.bss $< > $@

upload: $(BUILD)/program.hex
	/usr/bin/avrdude -v -V -p atmega2560 -D -c wiring -b 115200 -P /dev/ttyACM0 -U flash:w:$<:i

monitor:
	picocom -b 115200 --flow n --noreset --quiet /dev/ttyACM0

upload_monitor: upload monitor

clean:
	rm -f *.o *.elf *.hex *.dis 
	rm -rf $(BUILD)
