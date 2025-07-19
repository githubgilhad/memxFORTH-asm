#!/bin/bash
# vim: fileencoding=utf-8:nomodified:nowrap:textwidth=0:foldmethod=marker:foldcolumn=4:syntax=sh:filetype=sh:ruler:showcmd:lcs=tab\:|- list
#
avr-gcc -mmcu=atmega2560 -nostartfiles -o program.elf usart0_echo.S
avr-objdump --disassemble --source --line-numbers --demangle -z --section=.text  --section=.data --section=.bss program.elf > program.dis
#

