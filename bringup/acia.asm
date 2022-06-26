; CLOCK = 3.6864Mhz => 912MHz
;	/16 = 57600 bps

ACIA	EQU	0D800H
ACIACS	EQU	ACIA+0
ACIADA	EQU	ACIA+1

	.base	0xE000
	.org	0xE000
START:
        LDA	#$03
        STA	ACIACS
        NOP
        NOP
        NOP
        LDA	#$15    ; 0,00,101,01: no rx irq, RTS=low no tx irq, /16, N81 NON-INTERRUPT
        STA	ACIACS
1:
	LDX	#message
2:
        LDA	ACIACS
        ASR	A    
        ASR	A    
        BCC     2b
 	LDA	0,X
	BEQ	1b
	STA	ACIADA
	INX
	BRA	2b

message:
	.asciz	"This is the message\r\n"

	.org	0xFFF8
IRQ:
	.word	START
SOFT:
	.word	START
NMI:
	.word	START
RESET:
	.word	START

	.end
