#ifndef FS_WRAPPER_H
#define FS_WRAPPER_H

#include "ff.h"
#include <stdint.h>

uint8_t fs_init(void);

uint8_t fs_open_read(const char *path);
uint8_t fs_open_write(const char *path);

uint16_t fs_read(void *buf, uint16_t len);
uint16_t fs_write(const void *buf, uint16_t len);

void fs_close(void);

uint8_t fs_chdir(const char *path);
uint8_t fs_ls(void);

#endif
