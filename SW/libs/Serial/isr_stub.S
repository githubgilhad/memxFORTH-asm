
.section .text

.weak RESET                
RESET                :		;  0 Reset

.weak INT0_ISR             
INT0_ISR             :		;  1 External Interrupt Request 0

.weak INT1_ISR             
INT1_ISR             :		;  2 External Interrupt Request 1

.weak INT2_ISR             
INT2_ISR             :		;  3 External Interrupt Request 2

.weak INT3_ISR             
INT3_ISR             :		;  4 External Interrupt Request 3

.weak INT4_ISR             
INT4_ISR             :		;  5 External Interrupt Request 4

.weak INT5_ISR             
INT5_ISR             :		;  6 External Interrupt Request 5

.weak INT6_ISR             
INT6_ISR             :		;  7 External Interrupt Request 6

.weak INT7_ISR             
INT7_ISR             :		;  8 External Interrupt Request 7

.weak PCINT0_ISR           
PCINT0_ISR           :		;  9 Pin Change Interrupt Request 0

.weak PCINT1_ISR           
PCINT1_ISR           :		; 10 Pin Change Interrupt Request 1

.weak PCINT2_ISR           
PCINT2_ISR           :		; 11 Pin Change Interrupt Request 2

.weak WDT_ISR              
WDT_ISR              :		; 12 Watchdog Time-out Interrupt

.weak TIMER2_COMPA_ISR     
TIMER2_COMPA_ISR     :		; 13 Timer/Counter2 Compare Match A

.weak TIMER2_COMPB_ISR     
TIMER2_COMPB_ISR     :		; 14 Timer/Counter2 Compare Match B

.weak TIMER2_OVF_ISR       
TIMER2_OVF_ISR       :		; 15 Timer/Counter2 Overflow

.weak TIMER1_CAPT_ISR      
TIMER1_CAPT_ISR      :		; 16 Timer/Counter1 Capture Event

.weak TIMER1_COMPA_ISR     
TIMER1_COMPA_ISR     :		; 17 Timer/Counter1 Compare Match A

.weak TIMER1_COMPB_ISR     
TIMER1_COMPB_ISR     :		; 18 Timer/Counter1 Compare Match B

.weak TIMER1_COMPC_ISR     
TIMER1_COMPC_ISR     :		; 19 Timer/Counter1 Compare Match C

.weak TIMER1_OVF_ISR       
TIMER1_OVF_ISR       :		; 20 Timer/Counter1 Overflow

.weak TIMER0_COMPA_ISR     
TIMER0_COMPA_ISR     :		; 21 TimerCounter0 Compare Match A

.weak TIMER0_COMPB_ISR     
TIMER0_COMPB_ISR     :		; 22 TimerCounter0 Compare Match B

.weak TIMER0_OVF_ISR       
TIMER0_OVF_ISR       :		; 23 TimerCounter0 Overflow

.weak SPI_STC_ISR          
SPI_STC_ISR          :		; 24 SPI Serial Transfer Complete

.weak USART0_RX_ISR        
USART0_RX_ISR        :		; 25 USART0 Rx Complete

.weak USART0_UDRE_ISR      
USART0_UDRE_ISR      :		; 26 USART0, Data Register Empty

.weak USART0_TX_ISR        
USART0_TX_ISR        :		; 27 USART0, Tx Complete

.weak ANALOG_COMP_ISR      
ANALOG_COMP_ISR      :		; 28 Analog Comparator

.weak ADC_ISR              
ADC_ISR              :		; 29 ADC Conversion Complete

.weak EE_READY_ISR         
EE_READY_ISR         :		; 30 EEPROM Ready

.weak TIMER3_CAPT_ISR      
TIMER3_CAPT_ISR      :		; 31 Timer/Counter3 Capture Event

.weak TIMER3_COMPA_ISR     
TIMER3_COMPA_ISR     :		; 32 Timer/Counter3 Compare Match A

.weak TIMER3_COMPB_ISR     
TIMER3_COMPB_ISR     :		; 33 Timer/Counter3 Compare Match B

.weak TIMER3_COMPC_ISR     
TIMER3_COMPC_ISR     :		; 34 Timer/Counter3 Compare Match C

.weak TIMER3_OVF_ISR       
TIMER3_OVF_ISR       :		; 35 Timer/Counter3 Overflow

.weak USART1_RX_ISR        
USART1_RX_ISR        :		; 36 USART1 Rx Complete

.weak USART1_UDRE_ISR      
USART1_UDRE_ISR      :		; 37 USART1, Data Register Empty

.weak USART1_TX_ISR        
USART1_TX_ISR        :		; 38 USART1, Tx Complete

.weak TWI_ISR              
TWI_ISR              :		; 39 2-wire Serial Interface

.weak SPM_READY_ISR        
SPM_READY_ISR        :		; 40 Store Program Memory Ready

.weak TIMER4_CAPT_ISR      
TIMER4_CAPT_ISR      :		; 41 Timer/Counter4 Capture Event

.weak TIMER4_COMPA_ISR     
TIMER4_COMPA_ISR     :		; 42 Timer/Counter4 Compare Match A

.weak TIMER4_COMPB_ISR     
TIMER4_COMPB_ISR     :		; 43 Timer/Counter4 Compare Match B

.weak TIMER4_COMPC_ISR     
TIMER4_COMPC_ISR     :		; 44 Timer/Counter4 Compare Match C

.weak TIMER4_OVF_ISR       
TIMER4_OVF_ISR       :		; 45 Timer/Counter4 Overflow

.weak TIMER5_CAPT_ISR      
TIMER5_CAPT_ISR      :		; 46 Timer/Counter5 Capture Event

.weak TIMER5_COMPA_ISR     
TIMER5_COMPA_ISR     :		; 47 Timer/Counter5 Compare Match A

.weak TIMER5_COMPB_ISR     
TIMER5_COMPB_ISR     :		; 48 Timer/Counter5 Compare Match B

.weak TIMER5_COMPC_ISR     
TIMER5_COMPC_ISR     :		; 49 Timer/Counter5 Compare Match C

.weak TIMER5_OVF_ISR       
TIMER5_OVF_ISR       :		; 50 Timer/Counter5 Overflow

.weak USART2_RX_ISR        
USART2_RX_ISR        :		; 51 USART2 Rx Complete

.weak USART2_UDRE_ISR      
USART2_UDRE_ISR      :		; 52 USART2, Data Register Empty

.weak USART2_TX_ISR        
USART2_TX_ISR        :		; 53 USART2, Tx Complete

.weak USART3_RX_ISR        
USART3_RX_ISR        :		; 54 USART3 Rx Complete

.weak USART3_UDRE_ISR      
USART3_UDRE_ISR      :		; 55 USART3, Data Register Empty

.weak USART3_TX_ISR        
USART3_TX_ISR        :		; 56 USART3, Tx Complete


    reti
