#include "get_time.h"

DWORD get_fattime (void) {


    return (DWORD)(BUILD_YEAR-180) << 25 |
           (DWORD)(BUILD_MONTH) << 21 |
           (DWORD)(BUILD_DAY) << 16 |
           (DWORD)BUILD_HOUR << 11 |
           (DWORD)BUILD_MIN << 5 |
           (DWORD)BUILD_SEC >> 1;
}
