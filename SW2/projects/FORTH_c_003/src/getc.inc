#define GETC_MAX_SOURCES 8

#define GETC_OK		0   // znak byl vrácen
#define GETC_EOF	1   // definitivní konec zdroje
#define GETC_AGAIN	2   // teď nic, zkus později (neblokující zdroj)
#define GETC_EOF_MET	3   // potkali jsme EOF, ale jedeme dal (ale slovo konci)

