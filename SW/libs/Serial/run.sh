#!/bin/bash -x
# vim: fileencoding=utf-8:nomodified:nowrap:textwidth=0:foldmethod=marker:foldcolumn=4:syntax=sh:filetype=sh:ruler:showcmd:lcs=tab\:|- list
#
avr-gcc -c -mmcu=atmega2560 -nostartfiles -o usart0.o usart0.S
avr-gcc -c -mmcu=atmega2560 -nostartfiles -o program.o usart0_echo.S
avr-gcc -mmcu=atmega2560 -nostartfiles -o program.elf program.o usart0.o
avr-objdump --disassemble --source --line-numbers --demangle -z --section=.text  --section=.data --section=.bss program.elf > program.dis
avr-objcopy -O ihex program.elf program.hex
#

