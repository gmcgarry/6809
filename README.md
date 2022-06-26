----------------------------------------------------------------------------------------------------
Currently using minibug $FE00 which is good enough to load things
Doesn't support interrupt redirect. (i have patched the source though)

MONITR	$FEF8
OUTCH	$FEBF
INCH	$FE03

----------------------------------------------------------------------------------------------------
Now switched to SBUG

Use 'L' for LOAD,
then ^P to set the PC to 0100
then 'G' to goto PC

; CONTROL A   = ALTER THE "A" ACCUMULATOR
; CONTROL B   = ALTER THE "B" ACCUMULATOR
; CONTROL C   = ALTER THE CONDITION CODE REGISTER
; CONTROL D   = ALTER THE DIRECT PAGE REGISTER
; CONTROL P   = ALTER THE PROGRAM COUNTER
; CONTROL U   = ALTER USER STACK POINTER
; CONTROL X   = ALTER "X" INDEX REGISTER
; CONTROL Y   = ALTER "Y" INDEX REGISTER
; B hhhh      = SET BREAKPOINT AT LOCATION $hhhh
; E ssss-eeee = EXAMINE MEMORY FROM STARTING ADDRESS ssss
;              -TO ENDING ADDRESS eeee.
; G           = CONTINUE EXECUTION FROM BREAKPOINT OR SWI
; L           = LOAD TAPE
; M hhhh      = EXAMINE AND CHANGE MEMORY LOCATION hhhh
; P ssss-eeee = PUNCH TAPE, START ssss TO END eeee ADDR.
; Q ssss-eeee = TEST MEMORY FROM ssss TO eeee
; R           = DISPLAY REGISTER CONTENTS
; S           = DISPLAY STACK FROM ssss TO MONITOR STATE
; X           = REMOVE ALL BREAKPOINTS

E01B MONITOR
E049 NEXTCMD
E4A8 INCH	; input char
E4A2 INCHE	; input char with echo
E4B8 INCHEK	; kbhit
E4C7 OUTCH	; output char
E496 PDATA	; print data terminated with $04
E48A PCRLF	; print crlf
E486 PSTRNG	; print crlf + pdata

vector table is:

7FC2 SOFTWARE INTERRUPT VECTOR #3
7FC4 SOFTWARE INTERRUPT VECTOR #2
7FC6 FAST INTERRUPT VECTOR
7FC8 INTERRUPT VECTOR
7FCA SOFTWARE INTERRUPT VECTOR
7FCC SUPERVISOR CALL VECTOR ORGIN
7FCE SUPERVISOR CALL VECTOR LIMIT
