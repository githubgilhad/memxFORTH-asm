.section .vectors, "a", @progbits

    jmp RESET                ;  0 Reset
    jmp INT0_ISR             ;  1 External Interrupt Request 0
    jmp INT1_ISR             ;  2 External Interrupt Request 1
    jmp INT2_ISR             ;  3 External Interrupt Request 2
    jmp INT3_ISR             ;  4 External Interrupt Request 3
    jmp INT4_ISR             ;  5 External Interrupt Request 4
    jmp INT5_ISR             ;  6 External Interrupt Request 5
    jmp INT6_ISR             ;  7 External Interrupt Request 6
    jmp INT7_ISR             ;  8 External Interrupt Request 7
    jmp PCINT0_ISR           ;  9 Pin Change Interrupt Request 0
    jmp PCINT1_ISR           ; 10 Pin Change Interrupt Request 1
    jmp PCINT2_ISR           ; 11 Pin Change Interrupt Request 2
    jmp WDT_ISR              ; 12 Watchdog Time-out Interrupt
    jmp TIMER2_COMPA_ISR     ; 13 Timer/Counter2 Compare Match A
    jmp TIMER2_COMPB_ISR     ; 14 Timer/Counter2 Compare Match B
    jmp TIMER2_OVF_ISR       ; 15 Timer/Counter2 Overflow
    jmp TIMER1_CAPT_ISR      ; 16 Timer/Counter1 Capture Event
    jmp TIMER1_COMPA_ISR     ; 17 Timer/Counter1 Compare Match A
    jmp TIMER1_COMPB_ISR     ; 18 Timer/Counter1 Compare Match B
    jmp TIMER1_COMPC_ISR     ; 19 Timer/Counter1 Compare Match C
    jmp TIMER1_OVF_ISR       ; 20 Timer/Counter1 Overflow
    jmp TIMER0_COMPA_ISR     ; 21 TimerCounter0 Compare Match A
    jmp TIMER0_COMPB_ISR     ; 22 TimerCounter0 Compare Match B
    jmp TIMER0_OVF_ISR       ; 23 TimerCounter0 Overflow
    jmp SPI_STC_ISR          ; 24 SPI Serial Transfer Complete
    jmp USART0_RX_ISR        ; 25 USART0 Rx Complete
    jmp USART0_UDRE_ISR      ; 26 USART0, Data Register Empty
    jmp USART0_TX_ISR        ; 27 USART0, Tx Complete
    jmp ANALOG_COMP_ISR      ; 28 Analog Comparator
    jmp ADC_ISR              ; 29 ADC Conversion Complete
    jmp EE_READY_ISR         ; 30 EEPROM Ready
    jmp TIMER3_CAPT_ISR      ; 31 Timer/Counter3 Capture Event
    jmp TIMER3_COMPA_ISR     ; 32 Timer/Counter3 Compare Match A
    jmp TIMER3_COMPB_ISR     ; 33 Timer/Counter3 Compare Match B
    jmp TIMER3_COMPC_ISR     ; 34 Timer/Counter3 Compare Match C
    jmp TIMER3_OVF_ISR       ; 35 Timer/Counter3 Overflow
    jmp USART1_RX_ISR        ; 36 USART1 Rx Complete
    jmp USART1_UDRE_ISR      ; 37 USART1, Data Register Empty
    jmp USART1_TX_ISR        ; 38 USART1, Tx Complete
    jmp TWI_ISR              ; 39 2-wire Serial Interface
    jmp SPM_READY_ISR        ; 40 Store Program Memory Ready
    jmp TIMER4_CAPT_ISR      ; 41 Timer/Counter4 Capture Event
    jmp TIMER4_COMPA_ISR     ; 42 Timer/Counter4 Compare Match A
    jmp TIMER4_COMPB_ISR     ; 43 Timer/Counter4 Compare Match B
    jmp TIMER4_COMPC_ISR     ; 44 Timer/Counter4 Compare Match C
    jmp TIMER4_OVF_ISR       ; 45 Timer/Counter4 Overflow
    jmp TIMER5_CAPT_ISR      ; 46 Timer/Counter5 Capture Event
    jmp TIMER5_COMPA_ISR     ; 47 Timer/Counter5 Compare Match A
    jmp TIMER5_COMPB_ISR     ; 48 Timer/Counter5 Compare Match B
    jmp TIMER5_COMPC_ISR     ; 49 Timer/Counter5 Compare Match C
    jmp TIMER5_OVF_ISR       ; 50 Timer/Counter5 Overflow
    jmp USART2_RX_ISR        ; 51 USART2 Rx Complete
    jmp USART2_UDRE_ISR      ; 52 USART2, Data Register Empty
    jmp USART2_TX_ISR        ; 53 USART2, Tx Complete
    jmp USART3_RX_ISR        ; 54 USART3 Rx Complete
    jmp USART3_UDRE_ISR      ; 55 USART3, Data Register Empty
    jmp USART3_TX_ISR        ; 56 USART3, Tx Complete

    ; Vektory 57–72 jsou rezervované nebo unused (na adresách 0x0072 – 0x0091)
    ; V případě potřeby sem můžeš dát rjmp BADISR

    .rept 73 - 57
        jmp BADISR
    .endr

.section .text
nop
BADISR:
    reti
