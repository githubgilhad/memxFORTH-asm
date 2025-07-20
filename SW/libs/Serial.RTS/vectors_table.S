.section .vectors, "a", @progbits

    rjmp RESET                ;  0 Reset
    rjmp INT0_ISR             ;  1 External Interrupt Request 0
    rjmp INT1_ISR             ;  2 External Interrupt Request 1
    rjmp INT2_ISR             ;  3 External Interrupt Request 2
    rjmp INT3_ISR             ;  4 External Interrupt Request 3
    rjmp INT4_ISR             ;  5 External Interrupt Request 4
    rjmp INT5_ISR             ;  6 External Interrupt Request 5
    rjmp INT6_ISR             ;  7 External Interrupt Request 6
    rjmp INT7_ISR             ;  8 External Interrupt Request 7
    rjmp PCINT0_ISR           ;  9 Pin Change Interrupt Request 0
    rjmp PCINT1_ISR           ; 10 Pin Change Interrupt Request 1
    rjmp PCINT2_ISR           ; 11 Pin Change Interrupt Request 2
    rjmp WDT_ISR              ; 12 Watchdog Time-out Interrupt
    rjmp TIMER2_COMPA_ISR     ; 13 Timer/Counter2 Compare Match A
    rjmp TIMER2_COMPB_ISR     ; 14 Timer/Counter2 Compare Match B
    rjmp TIMER2_OVF_ISR       ; 15 Timer/Counter2 Overflow
    rjmp TIMER1_CAPT_ISR      ; 16 Timer/Counter1 Capture Event
    rjmp TIMER1_COMPA_ISR     ; 17 Timer/Counter1 Compare Match A
    rjmp TIMER1_COMPB_ISR     ; 18 Timer/Counter1 Compare Match B
    rjmp TIMER1_COMPC_ISR     ; 19 Timer/Counter1 Compare Match C
    rjmp TIMER1_OVF_ISR       ; 20 Timer/Counter1 Overflow
    rjmp TIMER0_COMPA_ISR     ; 21 TimerCounter0 Compare Match A
    rjmp TIMER0_COMPB_ISR     ; 22 TimerCounter0 Compare Match B
    rjmp TIMER0_OVF_ISR       ; 23 TimerCounter0 Overflow
    rjmp SPI_STC_ISR          ; 24 SPI Serial Transfer Complete
    rjmp USART0_RX_ISR        ; 25 USART0 Rx Complete
    rjmp USART0_UDRE_ISR      ; 26 USART0, Data Register Empty
    rjmp USART0_TX_ISR        ; 27 USART0, Tx Complete
    rjmp ANALOG_COMP_ISR      ; 28 Analog Comparator
    rjmp ADC_ISR              ; 29 ADC Conversion Complete
    rjmp EE_READY_ISR         ; 30 EEPROM Ready
    rjmp TIMER3_CAPT_ISR      ; 31 Timer/Counter3 Capture Event
    rjmp TIMER3_COMPA_ISR     ; 32 Timer/Counter3 Compare Match A
    rjmp TIMER3_COMPB_ISR     ; 33 Timer/Counter3 Compare Match B
    rjmp TIMER3_COMPC_ISR     ; 34 Timer/Counter3 Compare Match C
    rjmp TIMER3_OVF_ISR       ; 35 Timer/Counter3 Overflow
    rjmp USART1_RX_ISR        ; 36 USART1 Rx Complete
    rjmp USART1_UDRE_ISR      ; 37 USART1, Data Register Empty
    rjmp USART1_TX_ISR        ; 38 USART1, Tx Complete
    rjmp TWI_ISR              ; 39 2-wire Serial Interface
    rjmp SPM_READY_ISR        ; 40 Store Program Memory Ready
    rjmp TIMER4_CAPT_ISR      ; 41 Timer/Counter4 Capture Event
    rjmp TIMER4_COMPA_ISR     ; 42 Timer/Counter4 Compare Match A
    rjmp TIMER4_COMPB_ISR     ; 43 Timer/Counter4 Compare Match B
    rjmp TIMER4_COMPC_ISR     ; 44 Timer/Counter4 Compare Match C
    rjmp TIMER4_OVF_ISR       ; 45 Timer/Counter4 Overflow
    rjmp TIMER5_CAPT_ISR      ; 46 Timer/Counter5 Capture Event
    rjmp TIMER5_COMPA_ISR     ; 47 Timer/Counter5 Compare Match A
    rjmp TIMER5_COMPB_ISR     ; 48 Timer/Counter5 Compare Match B
    rjmp TIMER5_COMPC_ISR     ; 49 Timer/Counter5 Compare Match C
    rjmp TIMER5_OVF_ISR       ; 50 Timer/Counter5 Overflow
    rjmp USART2_RX_ISR        ; 51 USART2 Rx Complete
    rjmp USART2_UDRE_ISR      ; 52 USART2, Data Register Empty
    rjmp USART2_TX_ISR        ; 53 USART2, Tx Complete
    rjmp USART3_RX_ISR        ; 54 USART3 Rx Complete
    rjmp USART3_UDRE_ISR      ; 55 USART3, Data Register Empty
    rjmp USART3_TX_ISR        ; 56 USART3, Tx Complete

    ; Vektory 57–72 jsou rezervované nebo unused (na adresách 0x0072 – 0x0091)
    ; V případě potřeby sem můžeš dát rjmp BADISR

    .rept 73 - 57
        rjmp BADISR
    .endr

.section .text
nop
BADISR:
    reti
