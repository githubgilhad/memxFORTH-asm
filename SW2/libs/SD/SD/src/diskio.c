/*-----------------------------------------------------------------------*/
/* Low level disk I/O module SKELETON for FatFs     (C)ChaN, 2025        */
/*-----------------------------------------------------------------------*/
/* If a working storage control module is available, it should be        */
/* attached to the FatFs via a glue function rather than modifying it.   */
/* This is an example of glue functions to attach various exsisting      */
/* storage control modules to the FatFs module with a defined API.       */
/*-----------------------------------------------------------------------*/

#include "ff.h"			/* Basic definitions of FatFs */
#include "diskio.h"		/* Declarations FatFs MAI */

#include "sd_spi.h"

DSTATUS disk_initialize (BYTE pdrv)
{
    if (pdrv != 0) return STA_NOINIT;

    if (sd_init() == 0)
        return 0;

    return STA_NOINIT;
}

DSTATUS disk_status (BYTE pdrv)
{
    if (pdrv != 0) return STA_NOINIT;
    return 0;
}

DRESULT disk_read (
	BYTE pdrv,		/* Physical drive nmuber to identify the drive */
	BYTE *buff,		/* Data buffer to store read data */
	LBA_t sector,	/* Start sector in LBA */
	UINT count		/* Number of sectors to read */
)
{
    if (pdrv != 0 || count == 0)
        return RES_PARERR;

    while (count--)
    {
        if (sd_read_block(sector++, buff) != 0)
            return RES_ERROR;

        buff += 512;
    }

    return RES_OK;
}

DRESULT disk_write (BYTE pdrv, const BYTE* buff, LBA_t sector, UINT count)
{
    if (pdrv != 0 || count == 0)
        return RES_PARERR;

    while (count--)
    {
        if (sd_write_block(sector++, buff) != 0)
            return RES_ERROR;

        buff += 512;
    }

    return RES_OK;
}

DRESULT disk_ioctl (BYTE pdrv, BYTE cmd, void* buff)
{
    if (pdrv != 0) return RES_PARERR;

    switch (cmd)
    {
        case GET_SECTOR_SIZE:
            *(WORD*)buff = 512;
            return RES_OK;

        case GET_BLOCK_SIZE:
            *(DWORD*)buff = 1;
            return RES_OK;

        case CTRL_SYNC:
            return RES_OK;
    }

    return RES_PARERR;
}































