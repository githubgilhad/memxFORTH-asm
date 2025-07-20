BUILD = build-mega-atmega2560
# MCU & nástroje
MCU = atmega2560
CC = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump

LIB_DIR = ../../../libs

CFLAGS = -mmcu=$(MCU) -Wall -Os -nostartfiles
SRC = main.S
TARGET := $(notdir $(CURDIR))

# ========== Automatická detekce knihoven ==========
# Vyhledá řádky jako: ; LIBS: serial file

LIB_LINES := $(shell grep -i '^; *LIBS:' $(SRC)|sed "s/; *LIBS://")
# $(info $(foreach line,$(LIB_LINES),### $(line) ###))
LIBS := $(patsubst %,$(LIB_DIR)/%, $(LIB_LINES))
LIB_OBJS := $(addsuffix .o, $(LIBS))

OBJ = $(BUILD)/$(TARGET).o $(LIB_OBJS)

# $(info $(LIB_LINES) ## $(LIBS) ## $(LIB_OBJS) )

# ========== Build pravidla ==========

all: $(BUILD)/ $(BUILD)/$(TARGET).hex $(TARGET).dis

%/:
	mkdir -p $@

$(BUILD)/$(TARGET).elf: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

$(BUILD)/$(TARGET).o: $(SRC)
	$(CC) $(CFLAGS) -I$(dir $<)  -c $< -o $@

%.o: %.S
	$(MAKE) -C $(dir $<) $(BUILD)/$(notdir $@)
#	$(CC) $(CFLAGS) -I$(dir $<) -c $< -o $@

$(BUILD)/$(TARGET).hex: $(BUILD)/$(TARGET).elf
	$(OBJCOPY) -O ihex $< $@

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
