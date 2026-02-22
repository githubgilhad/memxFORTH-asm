#include "fs_wrapper.h"

static FATFS fs;
static FIL file;

uint8_t fs_init(void)
{
    if (f_mount(&fs, "", 1) == FR_OK)
        return 1;
    return 0;
}

uint8_t fs_open_read(const char *path)
{
    if (f_open(&file, path, FA_READ) == FR_OK)
        return 1;
    return 0;
}

uint8_t fs_open_write(const char *path)
{
    if (f_open(&file, path, FA_CREATE_ALWAYS | FA_WRITE) == FR_OK)
        return 1;
    return 0;
}

uint16_t fs_read(void *buf, uint16_t len)
{
    UINT br;
    if (f_read(&file, buf, len, &br) == FR_OK)
        return br;
    return 0;
}

uint16_t fs_write(const void *buf, uint16_t len)
{
    UINT bw;
    if (f_write(&file, buf, len, &bw) == FR_OK)
        return bw;
    return 0;
}

void fs_close(void)
{
    f_close(&file);
}

uint8_t fs_chdir(const char *path)
{
    if (f_chdir(path) == FR_OK)
        return 1;
    return 0;
}

uint8_t fs_ls(void)
{
    DIR dir;
    FILINFO fno;

    if (f_opendir(&dir, ".") != FR_OK)
        return 0;

    while (1)
    {
        if (f_readdir(&dir, &fno) != FR_OK || fno.fname[0] == 0)
            break;

        // tady můžeš volat FORTH print
        // např. forth_print(fno.fname);

    }

    f_closedir(&dir);
    return 1;
}
