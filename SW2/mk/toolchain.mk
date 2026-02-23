CC      := avr-gcc
AR      := avr-ar
OBJCOPY := avr-objcopy
SIZE    := avr-size
OBJDUMP  := avr-objdump

OPT := -Os
CSTD := -std=gnu11
WARN := -Wall -Wextra

DEPFLAGS := -MMD -MP
