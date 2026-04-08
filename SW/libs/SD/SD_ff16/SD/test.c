#include <stdint.h>
#include <avr/io.h>
#include <avr/interrupt.h>

#include "ff.h"
#include "diskio.h"
#include "../../../Serial.RTS/usart0/usart0.h"

FATFS fs;


int main(void)
{

	usart0_setup();
	sei();
	while (1) {
// ### SYNCPOINT alpha
// ### SYNCPOINT alpha
// ### SYNCPOINT alpha
		TX0_WriteStr("FatFs test\r\n");

		FRESULT res;

		for (uint8_t i=0;i<10;i++) {
			res = f_mount(&fs, "", 1);
			if (res != FR_OK)
			{
				TX0_WriteStr("f_mount error: ");
				TX0_WriteHex8(res);
				TX0_WriteStr("\r\n");
				//        while(1);
			} else break;
		}
		if (res != FR_OK) continue;
		TX0_WriteStr("Mounted OK\r\n");

		DIR dir;
		FILINFO fno;

		res = f_opendir(&dir, "/");
		if (res != FR_OK)
		{
			TX0_WriteStr("f_opendir error\r\n");
			if (res != FR_OK) continue;
		}

		TX0_WriteStr("Root dir:\r\n");

		while (1)
		{
			res = f_readdir(&dir, &fno);
			if (res != FR_OK || fno.fname[0] == 0)
				break;

			if (fno.fattrib & AM_DIR)
				TX0_WriteStr("[DIR] ");
			else
				TX0_WriteStr("      ");

			TX0_WriteStr(fno.fname);
			TX0_WriteStr("\r\n");
		}

		f_closedir(&dir);

		TX0_WriteStr("Done.\r\n");

		while(! RX0_Read()){;};
	};
}
