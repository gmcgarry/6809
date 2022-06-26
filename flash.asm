; 24LC256 w/ 64-byte pages
;
; board pinout:
; GND, D0 (SDA), D1 (SCL), VCC
;
; pinout:
;
;       +--v--+
;   A0 -|1   8|- VCC
;   A1 -|2   7|- WP
;   A2 -|3   6|- SCL
;  VSS -|4   5|- SDA
;       +-----+

.include 'oled/i2c.inc'

STACK	EQU	$7F00
ADDRESS	EQU	$50	; 1010 000x

; sbug
PUTC    EQU     $E4C7
MONITR  EQU     $E01B
GETCNE  EQU     $E4A8   ; no echo
GETC    EQU     $E4A2
PUTHEX  EQU     $E45A

	ORG     $0100
; ------------------------------------------------------------
RESET:
	LDS     #STACK
	JMP     MAIN

ACIACS  EQU     $D800
ACIADA  EQU     $D801
KBHIT   LDAA    ACIACS
	ASRA
	RTS

1:      BSR     PUTC
	INX
PUTS    LDAA    ,X
	BNE     1b
	RTS

; ------------------------------------------------------------
MAIN:
	LDX	#intro
	BSR	PUTS

LOOP:
	LDX	#crlf
	BSR	PUTS
	LDX	#prompt
	BSR	PUTS

	BSR	GETC

1:	CMPA	#'N'		; read next byte
	BNE	1f
	LDAA	#' '
	BSR	PUTC
	BSR	READNEXT
	BSR	PUTHEX
	BRA	LOOP

1:	CMPA	#'D'		; dump all
	BNE	1f
	BSR	DUMPMEM
	BRA	LOOP

1:	CMPA	#'W'		; write byte
	BNE	1f
	LDAA	#' '
	BSR	PUTC
	BSR	BADDR
	LDAA	#' '
	BSR	PUTC
	BSR	BYTE
	BSR	WRITEBYTE
	BSR	LOOP

1:	CMPA	#'B'		; block write
	BNE	1f
	LDAA	#' '
	BSR	PUTC
	BSR	BADDR
	LDAA	#' '
	BSR	PUTC
	BSR	BYTE
	BSR	WRITEBLOCK
	BSR	LOOP

1:	CMPA	#'R'		; read byte
	BNE	1f
	LDAA	#' '
	BSR	PUTC
	BSR	BADDR
	LDAA	#' '
	BSR	PUTC
	BSR	READBYTE
	BSR	PUTHEX
	BSR	LOOP


1:	CMPA	#'X'		; exit
	BNE	LOOP

	JMP	MONITR

intro:
	.asciz	"\r\n24LC512 driver\r\n"
crlf:
	.asciz "\r\n"
prompt:
	.asciz "# "


; ------------------------------------------------------------
ERROR:
	LDX	#error
	BSR	PUTS
	JMP	MONITR
error:	.asciz "ERROR: missing ACK\r\n"


XHI	DS	1
XLO	DS	1

; ------------------------------------------------------------
DUMPMEM:
	LDX	#$00

	BSR	i2c_start

	LDAA	#(ADDRESS<<1)
	BSR	i2c_write
	BCS	ERROR

	STX	XHI

	LDAA	XHI
	BSR	i2c_write
	BCS	ERROR

	LDAA	XLO
	BSR	i2c_write
	BCS	ERROR

	BSR	i2c_start

	LDAA	#(ADDRESS<<1)|1
	BSR	i2c_write
	BCS	ERROR

1:
	STX	XHI

	LDAA	XLO
	ANDA	#$0F
	BNE	2f

	LDAA	#'\r'
	BSR	PUTC
	LDAA	#'\n'
	BSR	PUTC
	LDAA	XHI
	BSR	PUTHEX
	LDAA	XLO
	BSR	PUTHEX
	LDAA	#':'
	BSR	PUTC

2:
	LDAA	#' '
	BSR	PUTC

	BSR	i2c_read
	BSR	i2c_ack

	BSR	PUTHEX

	BSR	KBHIT
	BCS	2f

	INX

	CPX	#$8000
	BNE	1b

2:
	BSR	i2c_read
	BSR	i2c_nack

	BSR	i2c_stop

	RTS

; ------------------------------------------------------------
; A=data
; X=address
WRITEBYTE:
	PSHA

	BSR	i2c_start

	LDAA	#(ADDRESS<<1)
	BSR	i2c_write
	BCS	ERROR

	STX	XHI

	LDAA	XHI
	BSR	i2c_write
	BCS	ERROR

	LDAA	XLO
	BSR	i2c_write
	BCS	ERROR

	PULA
	BSR	i2c_write
	BCS	ERROR

	BSR	i2c_stop

	RTS

; ------------------------------------------------------------
; A=data
; X=address
; block size = 128
WRITEBLOCK:
	PSHA

	BSR	i2c_start

	LDAA	#(ADDRESS<<1)
	BSR	i2c_write
	BCS	ERROR

	STX	XHI

	LDAA	XHI
	BSR	i2c_write
	BCS	ERROR

	LDAA	XLO
	BSR	i2c_write
	BCS	ERROR

	PULA

	LDAB	XLO
	ANDB	#$40-1
	NEGB
	ADDB	#$40
1:
	BSR	i2c_write
	BCS	ERROR
	DECB
	BNE	1b

	BSR	i2c_stop

	RTS

; ------------------------------------------------------------
WAITWRITE:
1:
	LDAA	#'X'
	BSR	PUTC

	BSR	i2c_start

	LDAA	#(ADDRESS<<1)
	BSR	i2c_write

	BSR	i2c_stop
	BCS	1b

	RTS

; ------------------------------------------------------------
; A=data
READNEXT:
	BSR	i2c_start

	LDAA	#(ADDRESS<<1)|1
	BSR	i2c_write
	BCS	ERROR

	BSR	i2c_read
	BSR	i2c_nack
	BSR	i2c_stop

	RTS

; ------------------------------------------------------------
; A=data
; X=address
READBYTE:
	BSR	i2c_start

	LDAA	#(ADDRESS<<1)
	BSR	i2c_write
	BCS	ERROR

	STX	XHI

	LDAA	XHI
	BSR	i2c_write
	BCS	ERROR

	LDAA	XLO
	BSR	i2c_write
	BCS	ERROR

	BSR	i2c_start

	LDAA	#(ADDRESS<<1)|1
	BSR	i2c_write
	BCS	ERROR

	BSR	i2c_read
	BSR	i2c_nack

	BSR	i2c_stop

	RTS


; BUILD ADDRESS
BADDR   BSR     BYTE    ; READ 2 FRAMES
	STAA    XHI
	BSR     BYTE
	STAA    XLO
	LDX     XHI     ; (X) ADDRESS WE BUILT
	RTS

; INPUT BYTE (TWO FRAMES)
BYTE    BSR     INHEX   ; GET HEX CHAR
	ASLA
	ASLA
	ASLA
	ASLA
	TAB
	BSR     INHEX
	ANDA    #$0F    ; MASK TO 4 BITS
	ABA
	RTS

; INPUT HEX CHAR
INHEX   BSR     GETC
	CMPA    #'0'
	BMI     C1      ; NOT HEX
	CMPA    #'9'
	BLE     IN1HG
	CMPA    #'A'
	BMI     C1      ; NOT HEX
	CMPA    #'F'
	BGT     C1      ; NOT HEX
	SUBA    #7
IN1HG   RTS

C1	JMP	MONITR

	END
