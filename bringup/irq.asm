; interrupt on ACIA

; CR:
;   CR7 - interrupts enabled (RX full, overrun, no DCD)
;   CR5:CR6 - 00=RTS low tx irq disabled, 01=RTS low tx irq enabled, 10=RTS high tx irq disabled, 11=break
;   CR4:CR3:CR2 - 101=N81
;   CR1:CR0 - 00=/1, 01=/16 (115200), 10=/64, 11=reset
; STATUS:
;   7:IRQ
;   6:PE (parity error)
;   5:OVRN (overrun)
;   4:FE (framing error)
;   3:/CTS
;   2:/DCD
;   1:TDRE (transmit empty)
;   0:RDRF (receive full)

ACIA	EQU	$D800
ACIACS	EQU	ACIA+0
ACIADA	EQU	ACIA+1

	ORG	$0100
START:
	LDS	#$00FF

	SEI	; disable interrupts

        LDA	#$03
        STA	ACIACS
        NOP
        NOP
        NOP
        LDA	#$95    ; 1,00,101,01: interrupt enabled, RTS=low no tx irq, N81, /16
        STA	ACIACS
	TST	ACIADA

	LDX	#ISR
	STX	$7FC8

	CLI	; enable interrupts

	; will drop to monitor on interrupt
	JMP	.

ISR:
	LDA	ACIADA
	LDA	#'X'
	STA	ACIADA
	RTI

	END
