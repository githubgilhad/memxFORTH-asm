#pragma once

#include "ff.h"

DWORD get_fattime (void);

#include <stdio.h>

/* ---------- ROK ---------- */
#define BUILD_YEAR  \
    ((__DATE__[7] - '0') * 1000 + \
     (__DATE__[8] - '0') * 100  + \
     (__DATE__[9] - '0') * 10   + \
     (__DATE__[10] - '0'))

/* ---------- DEN ---------- */
#define BUILD_DAY \
    ((__DATE__[4] == ' ' ? 0 : (__DATE__[4] - '0') * 10) + \
     (__DATE__[5] - '0'))

/* ---------- MĚSÍC ---------- */
#define BUILD_MONTH ( \
    __DATE__[0] == 'J' && __DATE__[1] == 'a' ? 1 : \
    __DATE__[0] == 'F' ? 2 : \
    __DATE__[0] == 'M' && __DATE__[2] == 'r' ? 3 : \
    __DATE__[0] == 'A' && __DATE__[1] == 'p' ? 4 : \
    __DATE__[0] == 'M' && __DATE__[2] == 'y' ? 5 : \
    __DATE__[0] == 'J' && __DATE__[2] == 'n' ? 6 : \
    __DATE__[0] == 'J' && __DATE__[2] == 'l' ? 7 : \
    __DATE__[0] == 'A' && __DATE__[1] == 'u' ? 8 : \
    __DATE__[0] == 'S' ? 9 : \
    __DATE__[0] == 'O' ? 10 : \
    __DATE__[0] == 'N' ? 11 : \
    12)

/* ---------- ČAS ---------- */
#define BUILD_HOUR \
    ((__TIME__[0] - '0') * 10 + (__TIME__[1] - '0'))

#define BUILD_MIN \
    ((__TIME__[3] - '0') * 10 + (__TIME__[4] - '0'))

#define BUILD_SEC \
    ((__TIME__[6] - '0') * 10 + (__TIME__[7] - '0'))

/*
int main(void)
{
    printf("Rok: %d\n", BUILD_YEAR);
    printf("Mesic: %d\n", BUILD_MONTH);
    printf("Den: %d\n", BUILD_DAY);
    printf("Hodina: %d\n", BUILD_HOUR);
    printf("Minuta: %d\n", BUILD_MIN);
    printf("Sekunda: %d\n", BUILD_SEC);

    return 0;
}
*/
