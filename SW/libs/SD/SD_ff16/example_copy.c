uint8_t bufferA[512];
uint8_t bufferB[512];

void copy_file(void)
{
    uint16_t n;
    uint8_t toggle = 0;

    fs_open_read("/INPUT.TXT");
    fs_open_write("/OUTPUT.TXT");

    while (1)
    {
        if (toggle == 0)
            n = fs_read(bufferA, 512);
        else
            n = fs_read(bufferB, 512);

        if (n == 0)
            break;

        if (toggle == 0)
            fs_write(bufferA, n);
        else
            fs_write(bufferB, n);

        toggle ^= 1;
    }

    fs_close();
}
