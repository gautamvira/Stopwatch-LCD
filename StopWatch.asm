ORG 0000H
SEC EQU 30H
MIN EQU 31H
HOUR EQU 32H
CLR A
	CLR P1.3		; clear RS - indicates that instructions are being sent to the module

; function set	
	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	CLR P1.4		; | high nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	CALL DELAY2		; wait for BF to clear	
					; function set sent for first time - tells module to go into 4-bit mode
; Why is function set high nibble sent twice? See 4-bit operation on pages 39 and 42 of HD44780.pdf.

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E
					; same function set high nibble sent a second time

	SETB P1.7		; low nibble set (only P1.7 needed to be changed)

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E
				; function set low nibble sent
	CALL DELAY2		; wait for BF to clear


; entry mode set
; set to increment with no shift
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	SETB P1.6		; |
	SETB P1.5		; |low nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	CALL delay2		; wait for BF to clear


; display on/off control
; the display is turned on, the cursor is turned on and blinking is turned on
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	SETB P1.7		; |
	SETB P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	CALL delay2		; wait for BF to clear

	SETB P1.3		; clear RS - indicates that data is being sent to module
	MOV R1, #40H	; data to be sent to LCD is stored in 8051 RAM, starting at location 30H

AJMP MAIN

MAIN:
LCALL CLEAR
HERE: JB P2.0, HERE
CLOCK:
CLR A
MOV MIN, A
MOV 43H, #'0'
MOV 44H, #'0'
MOV R4, #6
THIS2:
MOV B, #10
MOV 44H, #'0'
AGAIN:
CLR A
MOV 46H, #'0'
MOV 47H, #'0'
MOV SEC, A
MOV R3, #6
BACK:
MOV 47H, #'0'
MOV PSW, #18H
MOV R2, #10
THIS:
JB P2.0, HERE
JNB P2.1, CLEAR
ACALL SETV
ACALL DELAY
ACALL DELAY
ACALL COMN


INC SEC
INC 47H
DJNZ R2, THIS
CLR A
MOV A, PSW
INC 46H
DJNZ R3, BACK
INC MIN
INC 44H
DJNZ B, AGAIN
INC 43H
DJNZ R4, THIS2
INC HOUR
INC 41H
SJMP CLOCK

CLEAR:
CLR A
MOV HOUR, A
MOV MIN, A
MOV SEC, A
MOV 40H, #'0'
MOV 41H, #'0'
MOV 42H, #' '
MOV 43H, #'0'
MOV 44H, #'0'
MOV 45H, #' '
MOV 46H, #'0'
MOV 47H, #'0'
ACALL DELAY
ACALL DELAY1
SJMP CLOCK

DELAY: MOV R7, #250
BACK1: ACALL DELAY1
ACALL DELAY1
DJNZ R7, BACK1
RET
DELAY1: MOV R6, #250
MOV R5, #250
AGAIN1: DJNZ R5, AGAIN1
NEXT: DJNZ R6, NEXT
RET

SETV:
MOV R1, #40H
loop:
	MOV A, @R1	
	JZ FINISH	; move data pointed to by R1 to A		; if A is 0, then end of data has been reached - jump out of loop
	CALL sendCharacter	; send data in A to LCD module
	INC R1			; point to next piece of data
	JMP loop	

sendCharacter:
	MOV C, ACC.7		; |
	MOV P1.7, C			; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB P1.2			; |
	CLR P1.2			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB P1.2			; |
	CLR P1.2			; | negative edge on E

	CALL DELAY2

FINISH:
 RET

DELAY2: MOV R0, #50
DJNZ R0, $
RET

COMN:
	CLR P1.3
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E
	
	CLR P1.7
	CLR P1.6		; |
	CLR P1.5
	SETB P1.4		; |low nibble set
	
	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	ACALL delay1
ACALL DELAY1
	SETB P1.3	
RET
