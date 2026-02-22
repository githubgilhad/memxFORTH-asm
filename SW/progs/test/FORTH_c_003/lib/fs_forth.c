#include "ff.h"
#include "fs_forth.h"

static FATFS fs;
static FIL file;
static uint8_t mounted = 0;
static uint8_t file_open = 0;

uint8_t fs_init(void)
{
    if (mounted)
        return 0;

    if (f_mount(&fs, "", 1) == FR_OK)
    {
        mounted = 1;
        return 0;
    }

    return 1;
}

uint8_t fs_open_r(const char *path)
{
    if (!mounted) return 2;

    if (f_open(&file, path, FA_READ) == FR_OK)
    {
        file_open = 1;
        return 0;
    }

    return 1;
}

uint8_t fs_open_w(const char *path)
{
    if (!mounted) return 2;

    if (f_open(&file, path, FA_CREATE_ALWAYS | FA_WRITE) == FR_OK)
    {
        file_open = 1;
        return 0;
    }

    return 1;
}

uint8_t fs_open_a(const char *path)
{
    if (!mounted) return 2;

    if (f_open(&file, path, FA_OPEN_APPEND | FA_WRITE) == FR_OK)
    {
        file_open = 1;
        return 0;
    }

    return 1;
}

uint16_t fs_read(void *buf, uint16_t len)
{
    if (!file_open) return 0;

    UINT br;
    if (f_read(&file, buf, len, &br) == FR_OK)
        return br;

    return 0;
}

uint16_t fs_write(const void *buf, uint16_t len)
{
    if (!file_open) return 0;

    UINT bw;
    if (f_write(&file, buf, len, &bw) == FR_OK)
        return bw;

    return 0;
}

uint8_t fs_close(void)
{
    if (!file_open) return 1;

    if (f_close(&file) == FR_OK)
    {
        file_open = 0;
        return 0;
    }

    return 1;
}

uint8_t fs_seek(uint32_t pos)
{
    if (!file_open) return 1;

    if (f_lseek(&file, pos) == FR_OK)
        return 0;

    return 1;
}

uint32_t fs_tell(void)
{
    if (!file_open) return 0;
    return f_tell(&file);
}

uint32_t fs_size(void)
{
    if (!file_open) return 0;
    return f_size(&file);
}

uint8_t fs_cd(const char *path)
{
    return (f_chdir(path) == FR_OK) ? 0 : 1;
}

uint8_t fs_ls(void)
{
    DIR dir;
    FILINFO fno;

    if (f_opendir(&dir, ".") != FR_OK)
        return 1;

    while (1)
    {
        if (f_readdir(&dir, &fno) != FR_OK || fno.fname[0] == 0)
            break;

        // Tady zavolej FORTH print
        // například extern void forth_print(const char*);
        // forth_print(fno.fname);
    }

    f_closedir(&dir);
    return 0;
}
