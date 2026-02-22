#include <stdint.h>


#define MAX_SOURCES 8

#define GETC_OK        0   // znak byl vrácen
#define GETC_EOF       1   // definitivní konec zdroje
#define GETC_AGAIN     2   // teď nic, zkus později (neblokující zdroj)

typedef struct input_source input_source_t;

typedef uint8_t (*getc_fn)(input_source_t *src, uint8_t *out_char);

struct input_source {
    getc_fn getc;
    void *state;
};


typedef struct {
    input_source_t *stack[MAX_SOURCES];
    int8_t top;
} input_stack_t;



uint8_t input_getc(input_stack_t *s, uint8_t *out)
{
    while (s->top >= 0) {
        input_source_t *src = s->stack[s->top];
        uint8_t r = src->getc(src, out);

        if (r == GETC_OK)
            return GETC_OK;

        if (r == GETC_AGAIN)
            return GETC_AGAIN;

        if (r == GETC_EOF) {
            s->top--;   // zdroj vyčerpán
            continue;
        }

        return r; // error
    }

    return GETC_EOF;
}
