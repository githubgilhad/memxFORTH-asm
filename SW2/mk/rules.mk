MAKEFLAGS += --no-print-directory --no-builtin-rules

-include $(ROOT_DIR)/mk/colors.mk

MK_DEP += Makefile config.mk $(ROOT_DIR)/mk/*
BUILD_DIR ?= build
OBJ_DIR   := $(BUILD_DIR)/obj

CFLAGS += $(OPT) $(CSTD) $(WARN)
CFLAGS += -DF_CPU=$(F_CPU)
CFLAGS += $(addprefix -I,$(INC_DIRS))
CFLAGS_NODEP := $(CFLAGS)
CFLAGS +=  $(DEPFLAGS)

VERBOSE ?= 0

HEAD = @echo -e "$(COLORS)$(BRIGHTMAGENTA)m$@$(COLORS)$(RESET)m:"

ifeq ($(VERBOSE),1)
	Q :=
else
	Q := @
endif
# ----------------------------------------------------
# zdroje
# ----------------------------------------------------

PORT ?=  $(firstword $(wildcard /dev/ttyA-* /dev/ttyAr* /dev/ttyTot* /dev/ttyUSB* /dev/ttyACM* /dev/null) )
SRC_ABS := $(PROJECT_SRC) $(LIB_SRC)

# převedeme na absolutní cesty
SRC_ABS := $(abspath $(SRC_ABS))

# relativní vůči ROOT_DIR (kvůli umístění objektů)
SRC_REL := $(patsubst $(ROOT_DIR)/%,%,$(SRC_ABS))

# objekty
OBJ := $(addprefix $(OBJ_DIR)/,$(SRC_REL))
OBJ := $(OBJ:.c=.o)
OBJ := $(OBJ:.S=.o)

TARGET := $(BUILD_DIR)/$(PROJECT_NAME)

LD_SCRIPT := $(wildcard linker.ld)

# Common flags
LDFLAGS_COMMON = 
#
# If linker.ld exists → add -T linker.ld
ifneq ($(LD_SCRIPT),)
	LDFLAGS += $(LDFLAGS_COMMON) -Wl,-T$(LD_SCRIPT)
else
	LDFLAGS += $(LDFLAGS_COMMON)
endif

all: nums $(TARGET).hex $(TARGET).dis sizecheck TODO WORDS tags 
nums:
	$(Q)for i in 1 2 3 4 5 6 7 8 9; do echo "#";done
# ----------------------------------------------------
# linkování
# ----------------------------------------------------

$(TARGET).elf: $(OBJ) 
	$(HEAD)
	$(Q)mkdir -p $(BUILD_DIR)
	$(Q)$(CC) $(LDFLAGS) $^ -o $@ -Wl,-Map=$(TARGET).map

$(TARGET).hex: $(TARGET).elf $(MK_DEP)
	$(HEAD)
	$(Q)$(OBJCOPY) -O ihex -R .eeprom $< $@

# ----------------------------------------------------
# kompilace C
# ----------------------------------------------------

$(OBJ_DIR)/%.o: $(ROOT_DIR)/%.c $(MK_DEP)
	$(HEAD)
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) $(CFLAGS) -c $< -o $@

# ----------------------------------------------------
# kompilace ASM
# ----------------------------------------------------

$(OBJ_DIR)/%.o: $(ROOT_DIR)/%.S $(MK_DEP)
	$(HEAD)
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)

-include $(OBJ:.o=.d)

.PHONY: all nums clean sizecheck ispload bootloader reset TODO WORDS upload_monitor upload monitor tags debug




$(TARGET).dis: $(TARGET).elf $(MK_DEP)
	$(HEAD)
	$(Q)$(OBJDUMP)   --disassemble --source --line-numbers --demangle -z --section=.text  --section=.data   --section=.highram --section=.bss  --section=.rodata --section=.FORTH_data $< > $@
	$(Q)if ( $(OBJDUMP) -h $< | grep -q "\.FORTH_data") ; then \
		$(OBJDUMP) -s -j .FORTH_data  $< >> $@ ; \
	fi
	$(Q)Elf.rb $(TARGET).elf $(TARGET).bin2 $(TARGET).xref2
	$(Q)AVRemu -d -m $(MCU)  -x $(TARGET).xref2 $(TARGET).bin2 >$(TARGET).dis2 || true

sizecheck: $(TARGET).dis 
	$(HEAD)
	$(Q)avr-size -A $(TARGET).elf | awk ' /\.text/ { text = $$2 } /\.FORTH_data/  { forth = $$2 } /\.data/ { data = $$2 } END {\
		total = text + forth + data;  \
		if (total > 262144) { \
			printf "FLASH overflow: %d bytes (limit 262144)\n", total; \
			exit 1 \
		} else { \
			printf "FLASH used: %d / 262144 bytes\n", total \
		} \
	}'
	$(Q)avr-size $(TARGET).elf $(TARGET).hex |myavrsize.py 
	$(Q)avr-objdump -h $(TARGET).elf | grep -E '\.lowram|\.highram|\.data|\.bss|\.FORTH'|sort -k 2 | awk ' { \
		name = $$2; \
		size_hex = $$3; \
		gsub(/^0x/, "", size_hex); \
		size_dec = strtonum("0x" size_hex); \
		print "\t" size_dec " bytes\t" name; \
		}'


upload: $(TARGET).hex reset sizecheck
	/usr/bin/avrdude -v -V -p $(MCU) -D -c wiring -b 115200 -P $(PORT) -U flash:w:$<:i

ispload: $(TARGET).hex sizecheck 
	/usr/bin/avrdude -v -p atmega2560 -c usbasp -b 115200 -e -U lock:w:0x3F:m -U efuse:w:0xFD:m -U hfuse:w:0xD1:m -U lfuse:w:0xBF:m
	/usr/bin/avrdude -v -p $(MCU) -D -c usbasp -b 115200                 -U flash:w:$<:i

bootloader:
	/usr/bin/avrdude -v -p atmega2560 -c usbasp -b 115200 -e -U lock:w:0x3F:m -U efuse:w:0xFD:m -U hfuse:w:0xD0:m -U lfuse:w:0xBF:m
	/usr/bin/avrdude -v -p atmega2560 -c usbasp -b 115200 -U flash:w:/usr/share/arduino/hardware/arduino/avr/bootloaders//stk500v2/stk500boot_v2_mega2560.hex:i

reset:
	if [ -x $(dir $(realpath $(lastword $(MAKEFILE_LIST))))ard-reset-arduino ] ; then $(dir $(realpath $(lastword $(MAKEFILE_LIST))))ard-reset-arduino  $(PORT); fi

TODO: $(TARGET).dis  sizecheck WORDS
	$(HEAD)
	$(Q)cd src;grep  --color=always -r "TODO\|FIXME"|grep -v "^.\[[[:digit:]][[:digit:]]m.\[Ktags.\[m.\[K.\[[[:digit:]][[:digit:]]m.\[K:"

WORDS: $(TARGET).dis  sizecheck
	$(HEAD)
	$(Q)find -name "*.S" -exec grep -h "^DEF" {} \;|sort>WORDS.list

monitor:
	picocom -b 115200 --flow n --noreset --quiet $(PORT)

upload_monitor: upload monitor

debug: $(TARGET).dis
	$(HEAD)
	$(Q)AVRe -e  $(TARGET).elf || true

tags:
	ctags -R .

