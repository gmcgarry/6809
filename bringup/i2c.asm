; I2C board
; register locations:
;  $8000,$8400,$8800,$8C00
;  $9000,$9400,$9800,$9C00

; sbug
PUTC    EQU     $E4C7
MONITR  EQU     $E01B

ACIACS	EQU	$D800
PORT	EQU	$8000

PORT2	EQU	$D000

	ORG	$0100

START	LDS	#$7F00
	JMP	MAIN

MAIN	LDX	#msg
	BSR	PUTS
1:
	LDAA	PORT
	LDAA	PORT2
	LDAA	PORT
	LDAA	PORT2
	LDAA	PORT
	LDAA	PORT2
	LDAA	PORT
	LDAA	PORT2
	LDAA	PORT
	LDAA	PORT2
	LDAA	PORT
	LDAA	PORT2
	LDAA	PORT
	LDAA	PORT2
	LDAA	PORT
	LDAA	PORT2
	LDAA	PORT
	LDAA	PORT2
	LDAA	PORT
	LDAA	PORT2
	LDAA	PORT
	LDAA	PORT2
	BSR	KBHIT
	BCC	1b
	JMP	MONITR

msg:	.asciz	"\r\nTesting I2C @8000\r\nHit any key to terminate\r\n"

KBHIT   LDAA    ACIACS
        ASRA
        RTS

1:	BSR	PUTC
	INX
PUTS	LDAA	,X
	BNE	1b
	RTS