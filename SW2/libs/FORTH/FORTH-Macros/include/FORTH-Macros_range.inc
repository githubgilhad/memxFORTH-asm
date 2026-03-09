// pomocná makra
#define CAT(a,b) CAT_I(a,b)
#define CAT_I(a,b) a##b

#define EMPTY()
#define DEFER(id) id EMPTY()
#define OBSTRUCT(id) id DEFER(EMPTY)()

// Eval pro opakovanou expanzi
#define EVAL0(...) __VA_ARGS__
#define EVAL1(...) EVAL0(EVAL0(EVAL0(__VA_ARGS__)))
#define EVAL2(...) EVAL1(EVAL1(EVAL1(__VA_ARGS__)))
#define EVAL3(...) EVAL2(EVAL2(EVAL2(__VA_ARGS__)))
#define EVAL4(...) EVAL3(EVAL3(EVAL3(__VA_ARGS__)))
#define EVAL5(...) EVAL4(EVAL4(EVAL4(__VA_ARGS__)))
#define EVAL6(...) EVAL5(EVAL5(EVAL5(__VA_ARGS__)))
#define EVAL(...) EVAL6(__VA_ARGS__)

// jednoduchý IF
#define IF(c) CAT(IF_,c)
#define IF_0(t,f) f
#define IF_1(t,f) t

// rovnost fallback (vrací 1 pokud a==b, 0 jinak)
#define PROBE() ~,1
#define SECOND(a,b,...) b
#define IS_PROBE(...) SECOND(__VA_ARGS__,0)

#define EQ(a,b) IS_PROBE(CAT(EQ_,CAT(a,b)))

// definice rovnosti pro 0..31
#define EQ_00 PROBE()
#define EQ_11 PROBE()
#define EQ_22 PROBE()
#define EQ_33 PROBE()
#define EQ_44 PROBE()
#define EQ_55 PROBE()
#define EQ_66 PROBE()
#define EQ_77 PROBE()
#define EQ_88 PROBE()
#define EQ_99 PROBE()
#define EQ_1010 PROBE()
#define EQ_1111 PROBE()
#define EQ_1212 PROBE()
#define EQ_1313 PROBE()
#define EQ_1414 PROBE()
#define EQ_1515 PROBE()
#define EQ_1616 PROBE()
#define EQ_1717 PROBE()
#define EQ_1818 PROBE()
#define EQ_1919 PROBE()
#define EQ_2020 PROBE()
#define EQ_2121 PROBE()
#define EQ_2222 PROBE()
#define EQ_2323 PROBE()
#define EQ_2424 PROBE()
#define EQ_2525 PROBE()
#define EQ_2626 PROBE()
#define EQ_2727 PROBE()
#define EQ_2828 PROBE()
#define EQ_2929 PROBE()
#define EQ_3030 PROBE()
#define EQ_3131 PROBE()

// inkrementace 0..31
#define INC(x) CAT(INC_,x)
#define INC_0 1
#define INC_1 2
#define INC_2 3
#define INC_3 4
#define INC_4 5
#define INC_5 6
#define INC_6 7
#define INC_7 8
#define INC_8 9
#define INC_9 10
#define INC_10 11
#define INC_11 12
#define INC_12 13
#define INC_13 14
#define INC_14 15
#define INC_15 16
#define INC_16 17
#define INC_17 18
#define INC_18 19
#define INC_19 20
#define INC_20 21
#define INC_21 22
#define INC_22 23
#define INC_23 24
#define INC_24 25
#define INC_25 26
#define INC_26 27
#define INC_27 28
#define INC_28 29
#define INC_29 30
#define INC_30 31
#define INC_31 31


// dekrementace 0..31
#define DEC(x) CAT(DEC_,x)
#define DEC_0 0
#define DEC_1 0
#define DEC_2 1
#define DEC_3 2
#define DEC_4 3
#define DEC_5 4
#define DEC_6 5
#define DEC_7 6
#define DEC_8 7
#define DEC_9 8
#define DEC_10 9
#define DEC_11 10
#define DEC_12 11
#define DEC_13 12
#define DEC_14 13
#define DEC_15 14
#define DEC_16 15
#define DEC_17 16
#define DEC_18 17
#define DEC_19 18
#define DEC_20 19
#define DEC_21 20
#define DEC_22 21
#define DEC_23 22
#define DEC_24 23
#define DEC_25 24
#define DEC_26 25
#define DEC_27 26
#define DEC_28 27
#define DEC_29 28
#define DEC_30 29
#define DEC_31 30



#define PUSH_REG(x)  r##x, 




#define RANGE_UP(a,b) \
PUSH_REG(a) \
IF(EQ(a,b))( \
    , \
    OBSTRUCT(_RANGE_UP)()(INC(a),b) \
)

#define RANGE_DOWN(a,b) \
PUSH_REG(a) \
IF(EQ(a,b))( \
    , \
    OBSTRUCT(_RANGE_DOWN)()(DEC(a),b) \
)

#define _RANGE_UP() RANGE_UP
#define _RANGE_DOWN() RANGE_DOWN


#define PUSHX(a,b) pushm EVAL(RANGE_UP(a,b))
#define POPX(a,b) popm EVAL(RANGE_DOWN(a,b)) ; try


.macro pushm regs:vararg
.irp r,\regs
    push \r
.endr
.endm

.macro popm regs:vararg
.irp r,\regs
    pop \r
.endr
.endm


