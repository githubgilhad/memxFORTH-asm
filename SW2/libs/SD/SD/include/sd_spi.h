#pragma once
#include <stdint.h>

uint8_t sd_init(void);
uint8_t sd_read_block(uint32_t lba, uint8_t *buf);
uint8_t sd_write_block(uint32_t lba, const uint8_t *buf);

