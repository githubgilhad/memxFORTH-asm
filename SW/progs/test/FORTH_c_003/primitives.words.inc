DEFWORD w_dup,		0,	"dup",		f_dup	// ( a -- a a ) duplicate top of stack
DEFWORD w_drop,		0,	"drop",		f_drop	// ( a -- ) drop top of stack
DEFWORD w_swap,		0,	"swap",		f_swap	// ( a b -- b a ) swap top two stack items
DEFWORD w_over,		0,	"over",		f_over	// ( a b -- a b a ) copy second stack item to top
DEFWORD w_plus,		0,	"plus",		f_plus	// ( a b -- a+b ) add top two stack items
DEFWORD w_minus,		0,	"minus",		f_minus	// ( a b -- a-b ) subtract top from second
DEFWORD w_times,		0,	"times",		f_times	// ( a b -- a*b ) multiply top two stack items (24-bit result, may overflow)
DEFWORD w_div,		0,	"div",		f_div	// ( a b -- a/b ) divide second by top
DEFWORD w_at,		0,	"at",		f_at	// ( addr -- value ) fetch cell from address
DEFWORD w_store,		0,	"store",		f_store	// ( value addr -- ) store cell to address
DEFWORD w_char_at,		0,	"char_at",		f_char_at	// ( addr -- byte ) fetch byte from address
DEFWORD w_char_store,		0,	"char_store",		f_char_store	// ( byte addr -- ) store byte to address
DEFWORD w_key,		0,	"key",		f_key	// ( -- char ) read character from serial
DEFWORD w_emit,		0,	"emit",		f_emit	// ( char -- ) output character to serial
DEFWORD w_exit,		0,	"exit",		f_exit	// exit from word
DEFWORD w_docol,		0,	"docol",		f_docol	// enter colon word
DEFWORD w_lit,		0,	"lit",		f_lit	// ( -- value ) push literal value 
