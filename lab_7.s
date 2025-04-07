	.data

	.global timer
	.global time_string
	.global time_elasped
	.global frame_count
	.global frame_string
	.global frames_elapsed
	.global text_on_gray
	.global gray_background

general:		.word			0x00000000

timer:			.word			0x00000000
time_string:	.string			0x1B, "[48;5;8mTime: "
time_elapsed:	.string			0x1B, "[48;5;8m      ", 0

frame_count:	.word			0x00000000
frame_string:	.string			0x1B, "[48;5;8mFrames: "
frames_elapsed:	.string			0x1B, "[48;5;8m        ", 0

text_on_gray:		.string		0x1B, "[48;5;8m"
gray_background:	.string		0x1B, "[48;5;8m"

random_value:	.word			0x00000000		; Not really random; value (1-taken from timer B

	.text

	.global	lab7
	.global uart_init
	.global uart_interrupt_init
	.global UART0_Handler
	.global gpio_interrupt_init
	.global gpio_btn_and_LED_init
	.global Switch_Handler
	.global timer_init
	.global Timer_Handler
	.global PlayClock_Timer_Handler
	.global GameTic_Timer_Handler
	.global int2string
	.global output_string
	.global randomInt

ptr_to_general			.word	general
ptr_to_timer:			.word 	timer
ptr_to_time_string:		.word 	time_string
ptr_to_time_elapsed:	.word	time_elapsed
ptr_to_frame_count:		.word	frame_count
ptr_to_frame_string:	.word	frame_string
ptr_to_frames_elapsed	.word	frames_elapsed
ptr_to_text_on_gray:	.word	text_on_gray
ptr_to_gray_background	.word	gray_background


lab7:
	PUSH {r4-r12,lr}			; Save registers to stack

	BL uart_init
	BL uart_interrupt_init
	BL gpio_btn_and_LED_init
	BL gpio_interrupt_init
	BL timer_init

	BL init_PlayClock
	BL init_GameTic
	B loop

randomInt:						; Loads a random (timer-based) integer into r0
								; The random number is based on the GameTic value (Timer 1A)

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

	MOV r4, #0x1050				; Store Timer 1 address (LSB) with GPTMTAV r4
	MOVT r4, #0x4003			; Timer 1 address (MSB) (it means General Purpose Timer A Value)
	LDR r0, [r4]				; Stores random value in r0

	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before


speed_up:						; Increase game speed

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

								; Get current game speed
	LDR r4, ptr_to_general		; Load general game info address into r4
	LDR r5, [r4]				; Load general game info into r5
	UBFX r6, r5, #23, #3		; Extract game ball speed (bits 23-25 in general) into r6

	CMP r6, #6					; Is game ball speed maxed out?
	BGE	exit_speed_up			; If so, do nothing

	BL disable_Timer1A			; Disable Timer 1A for modification

	CMP r6, #0					; Is game ball speed 0?
	BEQ starting_speed			; If so, increase speed to 35 FPS

	CMP r6, #1					; Is game ball speed 1?
	BEQ speed_2_cruise_control	; If so, increase speed to 40 FPS

	CMP r6, #2					; Is game ball speed 2?
	BEQ speed_3					; If so, increase speed to 45 FPS

	CMP r6, #3					; Is game ball speed 3?
	BEQ speed_4					; If so, increase speed to 50 FPS

	CMP r6, #4					; Is game ball speed 4?
	BEQ speed_5					; If so, increase speed to 55 FPS

	CMP r6, #5					; Is game ball speed 5?
	BEQ speed_6					; If so, increase speed to 60 FPS

disable_Timer1A:

	MOV r7, #0x1000				; Store Timer 1 base address (LSB) with GPTMTAILR offset in r7
	MOVT r7, #0x4003			; (MSB) General Purpose Timer (1)A Interval Load Register

								; Disable GameTic timer for modification
	LDRB r8, [r7, #0xC]			; Load contents of GPTMCTL (with offset) into r6
	AND r8, r8, #0xFE			; Mask contents of r6 to clear the Timer 1A Enable bit (0th Bit)
	STRB r8, [r7, #0xC]			; Transmit masked data to disable Timer 1A

	MOV pc, lr					; Return to what you were doing before

reenable_Timer1A:
								; Re-enable GameTic timer
	LDRB r8, [r7, #0xC]			; Load contents of GPTMCTL (with offset) into r6
	ORR r8, r8, #0x1			; Unmask contents of r5 to set the Timer A Enable bit (0th Bit)
	STRB r7, [r7, #0xC]			; Transmit masked data to enable Timer 1A

	B exit_speed_up				; Exit subroutine

starting_speed:					; Increase from 30 -> 35 FPS

								; Increase GameTic Interval Period to 60Hz
	MOV r8, #0xdf37				; Store period (of 457,144(/2^3)) Clock Tics) in r8
	LSL r8, r8, #3				; Multiply r6 * 2^3 for product of 457,144
	STR r8, [r7]				; Transmit period to GPTMTAILR

	ADD r6, r6, #1				; Increment game ball speed by 1
	BFI r5, r6, #23, #3			; Update general game info in r5
	STR r5, [r4]				; Store information in memory

	BL reenable_Timer1A			; Re-enable Timer 1A after modification

speed_2_cruise_control:			; Increase from 35 -> 40 FPS

								; Increase GameTic Interval Period to 60Hz
	MOV r8, #0x61a8				; Store period (of 400,000(/2^3)) Clock Tics) in r8
	LSL r8, r8, #4				; Multiply r6 * 2^4 for product of 400,000
	STR r8, [r7]				; Transmit period to GPTMTAILR

	ADD r6, r6, #1				; Increment game ball speed by 1
	BFI r5, r6, #23, #3			; Update general game info in r5
	STR r5, [r4]				; Store information in memory

	BL reenable_Timer1A			; Re-enable Timer 1A after modification

speed_3:						; Increase from 40 -> 45 FPS

								; Increase GameTic Interval Period to 60Hz
	MOV r8, #0x2b67				; Store period (of 355,552(/2^5)) Clock Tics) in r6
	LSL r8, r8, #5				; Multiply r6 * 2^5 for product of 355,552
	STR r8, [r7]				; Transmit period to GPTMTAILR

	ADD r6, r6, #1				; Increment game ball speed by 1
	BFI r5, r6, #23, #3			; Update general game info in r5
	STR r5, [r4]				; Store information in memory

	BL reenable_Timer1A			; Re-enable Timer 1A after modification

speed_4:						; Increase from 45 -> 50 FPS

								; Increase GameTic Interval Period to 60Hz
	MOV r8, #0x4e20				; Store period (of 320,000(/2^4)) Clock Tics) in r6
	LSL r8, r8, #4				; Multiply r6 * 2^4 for product of 320,000
	STR r8, [r7]				; Transmit period to GPTMTAILR

	ADD r6, r6, #1				; Increment game ball speed by 1
	BFI r5, r6, #23, #3			; Update general game info in r5
	STR r5, [r4]				; Store information in memory

	BL reenable_Timer1A			; Re-enable Timer 1A after modification

speed_5:						; Increase from 50 -> 55 FPS

								; Increase GameTic Interval Period to 60Hz
	MOV r8, #0x2383				; Store period (of 290,912(/2^5)) Clock Tics) in r6
	LSL r8, r8, #5				; Multiply r6 * 2^5 for product of 290,912
	STR r8, [r7]				; Transmit period to GPTMTAILR

	ADD r6, r6, #1				; Increment game ball speed by 1
	BFI r5, r6, #23, #3			; Update general game info in r5
	STR r5, [r4]				; Store information in memory

	BL reenable_Timer1A			; Re-enable Timer 1A after modification

speed_6:						; Increase from 55 -> 60 FPS

								; Increase GameTic Interval Period to 60Hz
	MOV r8, #0x8235				; Store period (of 266,664(/2^3)) Clock Tics) in r6
	LSL r8, r8, #3				; Multiply r6 * 2^3 for product of 266,664
	STR r8, [r7, #0x28]			; Transmit period to GPTMTAILR

	ADD r6, r6, #1				; Increment game ball speed by 1
	BFI r5, r6, #23, #3			; Update general game info in r5
	STR r5, [r4]				; Store information in memory

	BL reenable_Timer1A			; Re-enable Timer 1A after modification

exit_speed_up:
	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before


UART0_Handler:

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

	POP {r4-r12,lr}				; Restore registers from stack
	BX lr						; Return to what you were doing before


Switch_Handler:		; Handles SW1

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

								; Clear interrupt
	MOV r4, #0x541C				; Put GPIOCR offset with Port F Base Address in r4 (LSB)
	MOVT r4, #0x04002			; Put GPIO Port F Base Address in r4 (MSB)
	LDRB r5, [r4] 				; Load data from UARTCIR in r5
	MOV r6, #0x10				; Prepare r6 for masking (LSB)
	ORR r5, r5, r6				; Set 4th bit (RXIC) in r5 (XXX1 XXXX)
	STRB r5, [r4]				; Store value from r5 in UARTCIR

	BL speed_up					; Increase game speed

	POP {r4-r12,lr}				; Restore registers from stack
	BX lr						; Return to what you were doing before


PlayClock_Timer_Handler:

	PUSH {r4-r12,lr}
								; Clear Interrupt
	MOV r4, #0x0024				; Store Timer 0 base address (LSB) with GPTMICR offset in r4
	MOVT r4, #0x4003			; Store Timer 0 base address (MSB) in r4
	LDR r5, [r4]				; Load data from GPTMICR into r5
	ORR r5, r5, #0x1			; Unmask contents, set TATOCINT (0th Bit)
	STR r5, [r4]				; Transmit unmasked contents to GPTMCIR

								; Do your thing here

								; Retrieve timer info from data, increment, and update
	LDR r4, ptr_to_timer		; Load timer address into r4
	LDR r5, [r4]				; Load timer value into r5
	ADD r5, r5, #1				; Increment timer value by 1
	STR r5, [r4]				; Store updated timer value in data

								; Convert new timer value to string and print
	MOV r1, r5					; Copy r5 into r1 to use as argument for int2string
	LDR r0, ptr_to_time_elapsed	; Copy timer string address into r0
	BL int2string				; Convert timer value (r1/int) into a string (in memory)
	; BL output_string			; Print new timer value

	BL randomInt				; Loads a random number in r0

	POP {r4-r12,lr}
	BX lr


GameTic_Timer_Handler:

	PUSH {r4-r12,lr}
								; Clear Interrupt
	MOV r4, #0x1024				; Store Timer 1 base address (LSB) with GPTMICR offset in r4
	MOVT r4, #0x4003			; Store Timer 1 base address (MSB) in r4
	LDR r5, [r4]				; Load data from GPTMICR into r5
	ORR r5, r5, #0x1			; Unmask contents, set TATOCINT (0th Bit)
	STR r5, [r4]				; Transmit unmasked contents to GPTMCIR

								; Do your thing here

								; Retrieve frame counter info from data & increment
	LDR r4, ptr_to_frame_count	; Load frame count address into r4
	LDR r5, [r4]				; Load frame count value into r5
	ADD r5, r5, #1				; Increment timer value by 1
	STR r5, [r4]				; Store updated timer value in data

									; Convert new timer value to string and print
	MOV r1, r5						; Copy r5 into r1 to use as argument for int2string
	BL int2string					; Convert timer value (r1/int) into a string (r0)
	LDR r6, ptr_to_frames_elapsed	; Copy timer string address into r6
	STR r0, [r6]					; Store new timer string in data
	; BL output_string				; Print new timer value


	POP {r4-r12,lr}
	BX lr


exit_lab7:
	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return


timer_init:

	PUSH {r4-r12,lr}			; Save registers to stack

								; Connect PlayClock & GameTic clocks to timer
	MOV r4, #0xE604				; Store Sytem Control base address (LSB) with RCGCTIMER offset in r4
	MOVT r4, #0x400F			; Store System Control base address in r4
	LDR r6, [r4]				; Load contents of RCGCTIMER into r6
	ORR r6, r6, #3				; Unmask contents & set Timers 0 & 1 bits (0th & 1st Bit) to 1
	STR r6, [r4]				; Transmit unmasked data to connect Timer 0 to clock


								; Disable PlayClock timer for setup
	MOV r4, #0x0				; Store Timer 0 (PlayClock) base address (LSB) in r4
	MOVT r4, #0x4003			; Store Timer 0 base address (MSB) in r4
	LDRB r6, [r4, #0xC]			; Load contents of GPTMCTL (with offset) into r6
	AND r6, r6, #0xFE			; Mask contents of r5 to clear the Timer 0A Enable bit (0th Bit)
	STRB r6, [r4, #0xC]			; Transmit masked data to disable Timer 0A

								; Disable GameTic timer for setup
	MOV r5, #0x1000				; Store Timer 1 (GameTic) base address (LSB) in r5
	MOVT r5, #0x4003			; Store Timer 1 base address (MSB) in r5
	LDRB r6, [r5, #0xC]			; Load contents of GPTMCTL (with offset) into r6
	AND r6, r6, #0xFE			; Mask contents of r6 to clear the Timer 1A Enable bit (0th Bit)
	STRB r6, [r5, #0xC]			; Transmit masked data to disable Timer 1A


								; Set up PlayClock timer for 32-Bit Mode
	LDRB r6, [r4]				; Load contents of GPTMCFG into r6
	AND r6, r6, #0x8			; Mask contents of r6 to clear bits 0-2
	STRB r6, [r4]				; Transmit masked data to choose Configuration 0 (32-bit mode)

								; Set up GameTic timer for 32-Bit Mode
	LDRB r6, [r5]				; Load contents of GPTMCFG into r6
	AND r6, r6, #0x8			; Mask contents of r6 to clear bits 0-2
	STRB r6, [r5]				; Transmit masked data to choose Configuration 0 (32-bit mode)


								; Put PlayClock timer into Periodic Mode
	LDRB r6, [r4, #0x4]			; Load contents of GPTMTAMR into r6
	ORR r6, r6, #0x2			; Unmask contents to set TAMR (bits 0-1) to 2
	STRB r6, [r4, #0x4]			; Transmit unmasked data to choose Configuration 2 (Periodic Mode)

								; Put GameTic timer into Periodic Mode
	LDRB r6, [r5, #0x4]			; Load contents of GPTMTAMR into r6
	ORR r6, r6, #0x2			; Unmask contents to set TAMR (bits 0-1) to 2
	STRB r6, [r5, #0x4]			; Transmit unmasked data to choose Configuration 2 (Periodic Mode)


								; Set up PlayClock Interval Period (of 1 second)
	MOV r6, #0x7A12				; Store period (of 16,000,000(/2^9) Clock Tics) in r6
	LSL r6, r6, #9				; Multiply r5 * 2^9 for product of 16 million (period = 1Hz)
	STR r6, [r4, #0x28]			; Transmit period to GPTMCTL (with offset)

								; Set up GameTic Interval Period (of 30Hz)
	MOV r6, #0x8235				; Store period (of 533,333(/2^4)) Clock Tics) in r6
	LSL r6, r6, #4				; Multiply r6 * 2^4 for product of 533,328 (period = 30Hz)
	STR r6, [r5, #0x28]			; Transmit period to GPTMCTL (with offset)


								; Enable Interrupts from PlayClock Timer 0A
	LDRB r6, [r4, #0x18]		; Load contents of GPTMIMR into r6
	ORR r6, r6, #1				; Unmask & set TATOIM bit (0th Bit)
	STRB r6, [r4, #0x18]		; Transmit data to enable Timer 0A Time Out Interrupt Mask

								; Enable Interrupts from GameTic Timer 1A
	LDRB r6, [r5, #0x18]		; Load contents of GPTMIMR into r6
	ORR r6, r6, #1				; Unmask & set TATOIM bit (0th Bit)
	STRB r6, [r5, #0x18]		; Transmit data to enable Timer 1A Time Out Interrupt Mask


								; Set the 19 bit in the EN0 register
	MOV r7, #0xE000				; Store EN0 base address in r7 (LSB)
	MOVT r7, #0xE000			; (MSB)
	LDR r6, [r7, #0x100]		; Load data from EN0 into r6
	ORR r6, r6, #0x280000		; Set the 19 and 21 bits to 1, enabling interrupts from
								;  Timers 0A and 1A respectively
	STR r6, [r7, #0x100]		; Store enabled bits in EN0


								; Re-enable PlayClock timer
	LDRB r6, [r4, #0xC]			; Load contents of GPTMCTL (with offset) into r6
	ORR r6, r6, #0x1			; Unmask contents of r5 to set the Timer A Enable bit (0th Bit)
	STRB r6, [r4, #0xC]			; Transmit masked data to enable Timer 0A

								; Re-enable GameTic timer
	LDRB r6, [r5, #0xC]			; Load contents of GPTMCTL (with offset) into r6
	ORR r6, r6, #0x1			; Unmask contents of r5 to set the Timer A Enable bit (0th Bit)
	STRB r6, [r5, #0xC]			; Transmit masked data to enable Timer 1A


	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return


init_PlayClock:					; Initialize data for game-playing time elapsed

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

	MOV r4, #0					; Copy zero value in r4
	LDR r5, ptr_to_timer		; Copy timer address to r5
	STR r4, [r5]				; Store zero value in "timer"

	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before


init_GameTic:					; Initialize data for game-speed timers

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

	MOV r4, #0					; Copy zero value in r4
	LDR r5, ptr_to_frame_count	; Copy timer address to r5
	STR r4, [r5]				; Store zero value in "timer"

	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before


loop:
	B loop						; Loop indefinitely


;Timer_Handler:					; This function has been subverted, Timers 0A & 1A
;								; trigger PlayClock_ & GameTic_Timer_Handlers instead.
;								; Refer to changes made in startup file (lines 110-112)
;
;	PUSH {r4-r12,lr}			; Save registers
;
;								; Check if Timer 0 triggered the interrupt
;	MOV r4, #0x101C				; Store Timer 0 base address (LSB) with GPTMIRS offset in r4
;	MOVT r4, #0x4003			; Store Timer 0 base address (MSB) in r4
;	LDR r5, [r4]				; Load data from GPTMIRS into r5
;	AND r5, r5, #1				; Mask data, preserving only LSB (TATORIS)
;	CMP r5, #1					; Check if TATORIS is set; this will be 1 if Timer 0A has been triggered
;	BNE PlayClock_Timer_Handler	; If Timer 0A Time-Out Raw Interrupt has been set, branch
;	CMP r5, #1
;	BEQ GameTic_Timer_Handler	; If not, Timer 1A is responsible, so branch there
;
;	POP {r4-r12,lr}				; Restore registers
;	MOV pc,lr					; Return


new_subroutine:					; Placeholder so I can copy/paste spilling & restoring registers

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before

	.end
