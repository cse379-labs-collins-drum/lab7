	.data

	.global timer
	.global time_string
	.global time_elasped
	.global frame_count
	.global frame_string
	.global frames_elapsed
	.global poweruptime
	.global player1_info
	.global player2_info
	.global powerupinfo
	.global poweruptime

	.global general
	.global move_cursor
	.global color
	.global draw_paddle
	.global board


; Start ball at 40 x, 14 y
general:		.word			0x08000E28		; general game information


player1_info:	.word		0x0000000C

; paddle position 12 = 0 1010
; powerup state 0
; score 0 = 000 0000
; color unknown = 000

; 0000 0000 0000 1010

player2_info:	.word		0x0000000C

; paddle position 12 = 0 1010
; powerup state 0
; score 0 = 000 0000
; color unknown = 000

; 0000 0000 0000 1010




powerupinfo:	.word			0x00000000		; powerup location & other info
poweruptime:	.word			0x00000000		; Time taken when powerup is first collected
powerup_countdown:	.word		0x00000000		; Time for powerup to respawn
random_value:	.word			0x00000000		; Not really random; value taken from timer 1A

timer:			.word			0x00000000
time_string:	.string			0x1B, "[48;5;8mTime: "
time_elapsed:	.string			0x1B, "[48;5;8m      ", 0

frame_count:	.word			0x00000000
frame_string:	.string			0x1B, "[48;5;8mFrames: "
frames_elapsed:	.string			0x1B, "[48;5;8m        ", 0

update_timer:			.string 0x18, 27, "[1;45H",0
move_cursor:		.string 0x1B, "[           ", 0
draw_paddle:			.string " ", 27, "[1D", 27, "[1B ", 27, "[1D", 27, "[1B ", 27, "[1D", 27, "[1B ", 27, "[1D", 27, "[1B", 0
color:			.string 0x10, 0
draw_pixel:		.string " ", 27, "[1D", 0
clear_cursor:	.string 27, "[?25l",0
score_string:	.string "          ",0
erase_left_paddle:		.string 0x10, 27, "[3;2H",0
erase_right_paddle:		.string 0x10, 27, "[3;81H",0

update_score_1:			.string 0x18, 27, "[1;11H",0
update_score_2:			.string 0x18, 27, "[1;71H",0

	.text

	.global uart_init
	.global uart_interrupt_init
	.global gpio_btn_and_LED_init
	.global gpio_interrupt_init
	.global int2string
	.global output_string
	.global simple_read_character
	.global output_ansi_string
	.global division
	.global rgb_led_color_to_escape_digit

	; .global Timer_Handler		; Does not trigger - program uses PlayClock_ and GameTic_Timer_Handlers instead

	.global	lab7

	.global Switch_Handler

	.global init_PlayClock
	.global init_GameTic
	.global PlayClock_Timer_Handler
	.global GameTic_Timer_Handler

	.global randomInt ; (OPTIONAL: Add modulo functionality? EDIT: No)
	.global clear_RGB_LED

	.global collect_powerup	; (TODO: double paddle sizes)
	.global do_the_LED_dance ; (OPTIONAL: Make dance fancier)
	.global deluminate_powerup
	.global illuminate_winner

	.global choose_game_length
	.global ALICE_interrupt_init
	.global ALICE_Button_Handler

	.global init_new_game
	.global init_new_round

	.global pause_game

	.global timer_init

	.global display_pause_menu
	.global remove_menu
	.global display_new_game_menu
	.global display_end_of_round

ptr_to_general:			.word	general
ptr_to_timer:			.word 	timer
ptr_to_time_string:		.word 	time_string
ptr_to_time_elapsed:	.word	time_elapsed
ptr_to_frame_count:		.word	frame_count
ptr_to_frame_string:	.word	frame_string
ptr_to_frames_elapsed:	.word	frames_elapsed
ptr_to_poweruptime:		.word	poweruptime
ptr_to_player1info		.word	player1_info
ptr_to_player2info		.word	player2_info
ptr_to_powerupinfo		.word	powerupinfo
ptr_to_move_cursor:		.word 	move_cursor
ptr_to_draw_paddle:		.word	draw_paddle
ptr_to_color:			.word	color
ptr_to_draw_pixel:		.word 	draw_pixel
ptr_to_clear_cursor:	.word	clear_cursor
ptr_to_update_timer:	.word 	update_timer
ptr_to_score_string:	.word 	score_string

ptr_to_update_score_1:	.word 	update_score_1
ptr_to_update_score_2:	.word 	update_score_2

ptr_to_erase_left_paddle:	.word	erase_left_paddle
ptr_to_erase_right_paddle:	.word	erase_right_paddle

ptr_to_board:				.word board

ptr_to_powerup_countdown:	.word	powerup_countdown


init_new_game:					; When a new game is started, initialize specific data

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

	BL clear_RGB_LED			; Deactivate Tiva RGB LED
	BL clear_ALICE_LEDs			; Deactivate ALICE LEDs
	BL remove_menu				; Clear menu from screen

								; Load & reset game data
	LDR r4, ptr_to_general		; Load general game data pointer in r4
	LDR r5, [r4]				; Load contents of general into r5
	MOV r5, #0					; Clear everything in
	STR r5, [r4]				; Update cleared info

								; Load & reset p1 data
	LDR r6, ptr_to_player1info	; Load player 1 info pointer in r6
	LDR r7, [r6]				; Load contents of p1 info into r7
	MOV r7, #0					; Clear everything in r7
	STR r7, [r6]				; Update cleared info


								; Load & reset p2 data
	LDR r8, ptr_to_player2info	; Load player 2 info pointer in r8
	LDR r9, [r8]				; Load contents of p2 info into r9
	MOV r9, #0					; Clear everything in r9
	STR r9, [r8]				; Update cleared info


								; Reset timer (don't reset frame counter)
	LDR r10, ptr_to_timer		; Load timer pointer in r10
	LDR r11, [r10]				; Load contents of timer into r11
	MOV r11, #0					; Clear everything in r11
	STR r11, [r10]				; Update timer

	BL choose_game_length		; Choose game length
	LDR r5, [r4]				; Retrieve updated game info (with score threshold)

								; IMPLEMENT THIS

								; Choose random color (1-7) for p1
	BL randomInt				; Get a random integer in r0
	MOV r1, #7					; Store divisor in r1 (r1 = 7)
	BL division					; Get the result of r0 % r1 (stored in r1)
	MOV r10, r1					; Save r1 value into r10 for later
	ADD r1, r1, #1				; Add 1 to r1 for range of 1-7
	BFI r7, r1, #13, #3			; Insert r1 into p1 info (Bits 13-15)

choose_p2_color:				; Choose new random color (1-7, less one) for p2
	BL randomInt				; Get a random integer in r0
	MOV r1, #7					; Store divisor in r1 (r1 = 7)
	BL division					; Get the result of r0 % r1 (stored in r1)
	CMP r1, r10					; See if random number is the same from player 1
	BEQ choose_p2_color			; If so, try again
	MOV r11, r1					; Save r1 value into r11 for later
	ADD r1, r1, #1				; Add 1 to r1 for range of 1-7
	BFI r9, r1, #13, #3			; Insert r1 into p2 info (Bits 13-15)

choose_ball_color:				; Choose new random color (1-7, less two) for ball
	BL randomInt				; Get a random integer in r0
	MOV r1, #7					; Store divisor in r1 (r1 = 7)
	BL division					; Get the result of r0 % r1 (stored in r1)
	CMP r1, r10					; See if random number is the same from player 1
	BEQ choose_ball_color		; If so, try again
	CMP r1, r11					; See if random number is the same from player 2
	BEQ choose_ball_color		; If so, try again
	ADD r1, r1, #1				; Add 1 to r1 for range of 1-7
	BFI r5, r1, #20, #3			; Insert r1 into general info (Bits 20-22)

								; Choose random ball placement x (21-60)
	BL randomInt				; Get a random integer in r0
	MOV r1, #40					; Store divisor in r1 (r1 = 40)
	BL division					; Get the result of r0 % r1 (stored in r1)
	ADD r1, r1, #21				; Add 21 to r1 for range of 21-60
	BFI r5, r1, #0, #8			; Insert r1 into general info (Bits 0-7)

								; Choose random ball placement y (5-20)
	BL randomInt				; Get a random integer in r0
	MOV r1, #16					; Store divisor in r1 (r1 = 16)
	BL division					; Get the result of r0 % r1 (stored in r1)
	ADD r1, r1, #5				; Add 1 to r1 for range of 5-20
	BFI r5, r1, #8, #5			; Insert r1 into general info (Bits 8-12)

	BFC r5, #13, #3				; Choose ball direction (0) (right) (p1 serves p2)

								; Center p1 & p2 paddle positions
	MOV r10, #10				; Store starting paddle position in r10
	BFI r7, r10, #0, #5			; Set p1 paddle position bits (Bits 0-4)
	BFI r9, r10, #0, #5			; Set p2 paddle position bits (Bits 0-4)

	STR r5, [r4]				; Update general game info
	STR r7, [r6]				; Update p1 info
	STR r9, [r8]				; Update p2 info

	BL reset_speed				; Reset in-game speed to 30 FPS


	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before


init_new_round:					; When a new round is started, initialize specific data

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

								; Check if score threshold has been met
	LDR r4, ptr_to_general		; Load general game data pointer in r4
	LDR r5, [r4]				; Load contents of general into r5

	LDR r6, ptr_to_player1info	; Load player 1 info pointer in r6
	LDR r7, [r6]				; Load contents of p1 info into r7

	LDR r8, ptr_to_player2info	; Load player 2 info pointer in r8
	LDR r9, [r8]				; Load contents of p2 info into r9

	UBFX r10, r5, #16, #4		; Place score threshold in r10 (general Bits 16-19)
	CMP r10, #0					; If score threshold is 0, unlimited play in effect (never game over)
	BEQ new_round_info			; If this is the case, skip next few lines

	UBFX r11, r7, #6, #7		; Place player 1's score in r11 (player1info Bits 6-12)
	CMP r11, r10				; Check if player score exceeds score threshold
	BGE set_game_over_p1		; If so, set game over bit and do not start new round

	UBFX r11, r9, #6, #7		; Place player 2's score in r11 (player2info Bits 6-12)
	CMP r11, r10				; Check if player score exceeds score threshold
	BGE set_game_over_p2		; If so, set game over bit and do not start new round

new_round_info:

	BFC r5, #30, #1				; Clear Bit 30 ("round over")

								; Choose random ball placement x (21-60)
	BL randomInt				; Get a random integer in r0
	MOV r1, #40					; Store divisor in r1 (r1 = 40)
	BL division					; Get the result of r0 % r1 (stored in r1)
	ADD r1, r1, #21				; Add 21 to r1 for range of 21-60
	BFI r5, r1, #0, #8			; Insert r1 into general info (Bits 0-7)

								; Choose random ball placement y (5-20)
	BL randomInt				; Get a random integer in r0
	MOV r1, #16					; Store divisor in r1 (r1 = 16)
	BL division					; Get the result of r0 % r1 (stored in r1)
	ADD r1, r1, #5				; Add 1 to r1 for range of 5-20
	BFI r5, r1, #8, #5			; Insert r1 into general info (Bits 8-12)

	TST r5, #0x20000000			; IF player 2 (right) won
	ITE NE
	MOVNE r1, #1				; Set the ball direction to straight left
	MOVEQ r1, #0				; ELSE set the ball direction to straight right

	BFI r5, r1, #13, #3			; Insert r1 into general info (Bits 13-15)

	;							; Center p1 & p2 paddle positions
	;MOV r10, #10				; Store starting paddle position in r10
	;BFI r7, r10, #0, #5			; Set p1 paddle position bits (Bits 0-4)
	;BFI r9, r10, #0, #5			; Set p2 paddle position bits (Bits 0-4)

	BL reset_speed				; Reset in-game speed to 30 FPS

	B exit_init_new_round		; Skip next instruction

set_game_over_p1:
	ORR r5, r5, #0x18000000		; Set "game over" and "player 1 won" bits in general game info
	BFC r5, #30, #1				; Clear "round over" bit

	BL display_new_game_menu
	B exit_init_new_round		; Skip next instruction

set_game_over_p2:
	ORR r5, r5, #0x28000000		; Set "game over" and "player 2 won" bits in general game info
	BFC r5, #30, #1				; Clear "round over" bit


	BL display_new_game_menu

exit_init_new_round:
	STR r5, [r4]				; Update general game info
	STR r7, [r6]				; Update p1 info
	STR r9, [r8]				; Update p2 info

	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before




ALICE_Button_Handler:			; Handles interrupts from the ALICE Board

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

								; Clear interrupt
	MOV r4, #0x741C				; Put GPIOICR offset with Port D Base Address in r4 (LSB)
	MOVT r4, #0x4000			; Put GPIO Port D Base Address in r4 (MSB)
	LDRB r5, [r4] 				; Load data from GPIOICR in r5
	ORR r5, r5, #0xF			; Set bits 0-3 in r5 (interrupt clear)
	STRB r5, [r4]				; Store value from r5 in GPIOICR

								; Do your thing here

									; Check if game is over. If not, do nothing
	LDR r4, ptr_to_general			; Load general game info address in r4
	LDR r5, [r4]					; Retrieve general info into r5
	TST r5, #0x8000000				; Test "Game Over" bit (Bit 27)
	BEQ exit_ALICE_button_handler	; If not set, exit subroutine

	MOV r4, #0x73FC					; Retrieve ALICE Button GPIO Data
	MOVT r4, #0x4000				; Move Port D's address into r6
	LDRB r2, [r4]					; Load Port D's data register into r2 for use as an argument later

	LDR r0, ptr_to_board

	BL output_ansi_string

	BL init_new_game				; Initialize a new game

exit_ALICE_button_handler:
	POP {r4-r12,lr}				; Restore registers from stack
	BX lr						; Return to what you were doing before











Switch_Handler:					; Handles SW1 - THIS SHOULD PAUSE THE GAME

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

								; Clear interrupt
	MOV r4, #0x541C				; Put GPIOCR offset with Port F Base Address in r4 (LSB)
	MOVT r4, #0x04002			; Put GPIO Port F Base Address in r4 (MSB)
	LDRB r5, [r4] 				; Load data from UARTCIR in r5
	MOV r6, #0x10				; Prepare r6 for masking (LSB)
	ORR r5, r5, r6				; Set 4th bit (RXIC) in r5 (XXX1 XXXX)
	STRB r5, [r4]				; Store value from r5 in UARTCIR

								; Do your thing here

								; Check if game is over. If so, do nothing
	LDR r4, ptr_to_general		; Load general game data pointer in r4
	LDR r5, [r4]				; Load contents of general into r5
	TST r5, #0x8000000			; Check the "game over" bit (Bit 27)
	BNE exit_Switch_Handler		; If bit is set, do nothing

								; Check if game is paused. If not, pause
	TST r5, #0x4000000			; Check if game is paused
	IT EQ
	BLEQ pause_game				; If bit is unset, pause game

	TST r5, #0x4000000			; Check if game is paused
	IT NE
	BLNE unpause_game			; If bit is set, unpause

	;BL set_p1_winner
	;BL init_new_round

exit_Switch_Handler:
	POP {r4-r12,lr}				; Restore registers from stack
	BX lr						; Return to what you were doing before





PlayClock_Timer_Handler:

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

								; Clear Interrupt
	MOV r4, #0x0024				; Store Timer 0 base address (LSB) with GPTMICR offset in r4
	MOVT r4, #0x4003			; Store Timer 0 base address (MSB) in r4
	LDR r5, [r4]				; Load data from GPTMICR into r5
	ORR r5, r5, #0x1			; Unmask contents, set TATOCINT (0th Bit)
	STR r5, [r4]				; Transmit unmasked contents to GPTMCIR

								; Do your thing here

										; Check if game is over/paused. If so, do nothing
	LDR r4, ptr_to_general				; Load general game data pointer in r4
	LDR r5, [r4]						; Load contents of general into r5
	TST r5, #0x4C000000					; Check the "paused", "game over", and "round over" bits (Bits 26-27 & 30)
	BNE exit_PlayClock_Timer_Handler	; If any bit is set, do nothing

										; Retrieve timer info from data, increment, and update
	LDR r4, ptr_to_timer				; Load timer address into r4
	LDR r5, [r4]						; Load timer value into r5
	ADD r5, r5, #1						; Increment timer value by 1
	STR r5, [r4]						; Store updated timer value in data

	LDR r0, ptr_to_update_timer

	BL output_ansi_string


								; Convert new timer value to string and print
	MOV r1, r5					; Copy r5 into r1 to use as argument for int2string
	LDR r0, ptr_to_time_elapsed	; Copy timer string address into r0
	BL int2string				; Convert timer value (r1/int) into a string (in memory)

	LDR r0, ptr_to_time_elapsed

	BL output_string

	BL deluminate_powerup		; Darken LEDs for powerup


exit_PlayClock_Timer_Handler:
	POP {r4-r12,lr}				; Restore registers from stack
	BX lr						; Return to what you were doing before





GameTic_Timer_Handler:

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

								; Clear Interrupt
	MOV r4, #0x1024				; Store Timer 1 base address (LSB) with GPTMICR offset in r4
	MOVT r4, #0x4003			; Store Timer 1 base address (MSB) in r4
	LDR r5, [r4]				; Load data from GPTMICR into r5
	ORR r5, r5, #0x1			; Unmask contents, set TATOCINT (0th Bit)
	STR r5, [r4]				; Transmit unmasked contents to GPTMCIR

								; Do your thing here

	LDR r4, ptr_to_frame_count			; Load frame count address into r4
	LDR r5, [r4]						; Load frame count value into r5
	ADD r5, r5, #1						; Increment timer value by 1
	STR r5, [r4]						; Store updated timer value in data

										; Check if game is over/paused. If so, do nothing
	LDR r4, ptr_to_general				; Load general game data pointer in r4
	LDR r5, [r4]						; Load contents of general into r5
	TST r5, #0x44000000					; Check the "paused" and "round over" bits (Bits 26 & 30), NOT "game over"
	BNE exit_GameTic_Timer_Handler		; If either bit is set, do nothing

	BL illuminate_winner				; If game is over, make the ALICE LEDs "Victory Dance"
	BL do_the_LED_dance

	TST r5, #0x8000000					; Check the "game over" bit (Bit 27)
	BNE exit_GameTic_Timer_Handler		; If either bit is set, do nothing

										; Retrieve frame counter info from data & increment


										; Convert new frame count value to string and print - USED FOR TESTING
	; MOV r1, r5						; Copy r5 into r1 to use as argument for int2string
	; BL int2string						; Convert timer value (r1/int) into a string (r0)
	; LDR r6, ptr_to_frames_elapsed		; Copy timer string address into r6
	; STR r0, [r6]						; Store new timer string in data
	; BL output_string					; Print new timer value


	; Load ball position from memory
	LDR r0, ptr_to_general

	LDR r4, [r0]				; Load the general game info into r4

	UBFX r5, r4, #0, #8			; Extract the ball's x position from general (into r5)
	UBFX r6, r4, #8, #5			; Extract the ball's y position from general (into r6)
	UBFX r7, r4, #13, #3		; Extract the ball's direction from general  (into r7)
	UBFX r12, r4, #20, #3		; Extract the ball's color from general  (into r12)

	LDR r0, ptr_to_move_cursor
	ADD r0, r0, #2				; Load the address of the move_cursor string, but move past
						; the first two escape sequence characters

	MOV r1, r6				; Copy the ball's y position into r1 (for int2string)

	BL int2string

	MOV r1, #0x3B				; Move ";" into r1
	STRB r1, [r0], #1			; Store the ";" into the string in memory

	MOV r1, r5				; Copy the ball's x position into r1 (for int2string)

	BL int2string

	MOV r1, #0x48		; Store "H" in r1

	STRB r1, [r0], #1

	MOV r1, #0
	STRB r1, [r0]				; Null terminate the string

	LDR r0, ptr_to_move_cursor

	BL output_ansi_string			; Move the cursor to the current ball position

	LDR r0, ptr_to_color

	MOV r1, #0x10				; Move the color black into r1

	STRB r1, [r0]				; Store the character into the string

	BL output_ansi_string			; Make the background color black

	LDR r0, ptr_to_draw_pixel

	BL output_ansi_string			; Draw a black pixel over the ball

	; Check collision

	CMP r5, #3
	BEQ left_paddle_check

	CMP r5, #80
	BEQ right_paddle_check

	CMP r6, #3
	BEQ top_boundary			; IF the y value is 3, branch to check top boundary collision

	CMP r6, #26
	BEQ bottom_boundary			; IF the y value is 26, branch to check the bottom boundary collision

	B move_ball				; Move the ball according to the current direction

left_paddle_check:

	LDR r2, ptr_to_player1info

	LDR r8, [r2]				; Load player 1's info

	UBFX r9, r8, #0, #5			; Copy the paddle position into r9

	TST r8, #0x20
	ITE EQ						; IF the powerup is off
	ADDEQ r10, r9, #3			; Set the bottom of the paddle 3 below the top
	ADDNE r10, r9, #7			; ELSE set it 7 below the top

	MOV r11, #0

	CMP r6, r9
	IT GE						; IF the ball position is below or even with top of the paddle
	ORRGE r11, r11, #1			; Set the LSB of r11

	CMP r6, r10
	IT LE						; IF the ball position is above or even with the top of the paddle
	ORRLE r11, r11, #2			; Set bit 1 of r11

	CMP r11, #3
	BEQ left_doesnt_lose


	; I want to conditionally BL, so I skip these two lines when the
	; ball is next to the paddle
	BL left_loses

	B exit_GameTic_Timer_Handler

left_doesnt_lose:

	; Here, the ball should bounce back

	BL speed_up

	MOV r7, #0					; Make the ball direction straight to the right

	ADD r3, r9, #2				; We need to check if the ball is on the top pixel of the paddle

	CMP r9, r6
	IT EQ						; IF the ball is on the top pixel of the paddle
	ORREQ r7, r7, #4			; Set the up bit of the ball direction

	SUB r3, r10, #2				; Checking if the ball is on the bottom pixel of the paddle

	CMP r10, r6
	IT EQ						; IF the ball is on the bottom of the paddle
	ORREQ r7, r7, #2			; Set the down bit of the ball direction

	B move_ball

right_paddle_check:

	LDR r2, ptr_to_player2info

	LDR r8, [r2]				; Load player 1's info

	UBFX r9, r8, #0, #5			; Copy the paddle position into r9

	TST r8, #0x20
	ITE EQ						; IF the powerup is off
	ADDEQ r10, r9, #3			; Set the bottom of the paddle 3 below the top
	ADDNE r10, r9, #7			; ELSE set it 7 below the top


	MOV r11, #0

	CMP r6, r9
	IT GE						; IF the ball position is below or even with top of the paddle
	ORRGE r11, r11, #1			; Set the LSB of r11

	CMP r6, r10
	IT LE						; IF the ball position is above or even with the top of the paddle
	ORRLE r11, r11, #2			; Set bit 1 of r11

	CMP r11, #3
	BEQ right_doesnt_lose


	; I want to conditionally BL, so I skip these two lines when the
	; ball is next to the paddle
	BL right_loses

	B exit_GameTic_Timer_Handler

right_doesnt_lose:

	; Here, the ball should bounce back

	BL speed_up

	MOV r7, #1					; Make the ball direction straight to the left

	CMP r9, r6
	IT EQ						; IF the ball is on the top pixel of the paddle
	ORREQ r7, r7, #4			; Set the up bit of the ball direction

	SUB r3, r10, #2				; Checking if the ball is on the bottom pixel of the paddle

	CMP r10, r6
	IT EQ						; IF the ball is on the bottom of the paddle
	ORREQ r7, r7, #2			; Set the down bit of the ball direction

	B move_ball

top_boundary:

	TST r7, #0x4
	IT NE						; IF the up bit is set,
	EORNE r7, r7, #0x6			; Flip both the up and down bits

	B move_ball					; Move the ball in the new direction

bottom_boundary:

	TST r7, #0x2
    IT NE					; IF the down bit is set
    EORNE r7, r7, #0x6      ; Flip both the up and down bits

    B move_ball				; Move the ball in the new direction

move_ball:
	; Calculate the new ball position
        ; We are storing the ball's direction as [Up bit | Down bit | left/right bit]
        ; for left/right, right = 0, left = 1

	TST r7, #0x4
    IT NE                                   ; IF the up bit is set,
    SUBNE r6, r6, #1                        ; Subtract one from the y position (move up a row)

    TST r7, #0x2
    IT NE                                   ; IF the down bit is set,
    ADDNE r6, r6, #1                        ; Add one to the y position (move down a row)

    TST r7, #0x1
    ITE NE                                  ; IF the left bit is set,
    SUBNE r5, r5, #1                        ; Add one to the x position (move one column to the right)
    ADDEQ r5, r5, #1                        ; Subtract one from the x position


draw_new_ball:
	; Draw the new ball

	LDR r0, ptr_to_move_cursor
    ADD r0, r0, #2                          ; Load the address of the move_cursor string, but move past
                                                ; the first two escape sequence characters

    MOV r1, r6                              ; Copy the ball's y position into r1 (for int2string)

    BL int2string

    MOV r1, #0x3B                           ; Move ";" into r1
    STRB r1, [r0], #1                       ; Store the ";" into the string in memory

    MOV r1, r5                              ; Copy the ball's x position into r1 (for int2string)
    BL int2string

	MOV r1, #0x48		; Store "H" in r1

	STRB r1, [r0], #1

    MOV r1, #0
    STRB r1, [r0]                           ; Null terminate the string

    LDR r0, ptr_to_move_cursor

    BL output_ansi_string                   ; Move the cursor to the current ball position

    LDR r0, ptr_to_color

    ;MOV r1, #0x14                           ; Move the color blue into r1 placeholderss

	PUSH {r0}

	MOV r0, r12

	BL rgb_led_color_to_escape_digit

	MOV r1, r0

	POP {r0}

    STRB r1, [r0]                           ; Store the character into the string

    BL output_ansi_string

    LDR r0, ptr_to_draw_pixel

    BL output_ansi_string                   ; Draw a colored pixel over the ball

    LDR r0, ptr_to_clear_cursor

	BL output_ansi_string


	LDR r0, ptr_to_general
	LDR r4, [r0]

	; Store the new ball info into general

	BFI r4, r5, #0, #8
	BFI r4, r6, #8, #5
	BFI r4, r7, #13, #3			; Store new x, y and direction into r4

	STR r4, [r0]				; Store the general data into memory



exit_GameTic_Timer_Handler:
	POP {r4-r12,lr}				; Restore registers from stack
	BX lr						; Return to what you were doing before

left_loses:

	PUSH {r4-r12, lr}

	LDR r4, ptr_to_player2info
	LDR r5, [r4]

	UBFX r6, r5, #6, #7

	ADD r6, r6, #1

	BFI r5, r6, #6, #7

	STR r5, [r4]

	LDR r4, ptr_to_general

	LDR r5, [r4]			; load general info into r5

	MOV r7, #2			; Set r7 = right wins

	BFI r5, r7, #28, #2		; Insert "right wins" into general info

	ORR r5, r5, #0x40000000				; Set "round over" bit
	; BL display_end_of_round

	STR r5, [r4]

	BL illuminate_winner				; Light LED for winner


	PUSH {r0, r1}

	LDR r0, ptr_to_score_string

	MOV r1, r6

	BL int2string

	LDR r0, ptr_to_update_score_2

	BL output_ansi_string

	LDR r0, ptr_to_score_string

	BL output_string

	;BL erase_left_paddle_srt

	;BL erase_right_paddle_srt

	POP {r0, r1}

	POP {r4-r12, lr}

	MOV pc, lr


right_loses:

	PUSH {r4-r12, lr}

	LDR r4, ptr_to_player1info
	LDR r5, [r4]

	UBFX r6, r5, #6, #7

	ADD r6, r6, #1

	BFI r5, r6, #6, #7

	STR r5, [r4]

	LDR r4, ptr_to_general

	LDR r5, [r4]			; Load general info into r5

	MOV r7, #1			; Load "left wins" into r7

	BFI r5, r7, #28, #1		; Insert "left wins" into general info

	ORR r5, r5, #0x40000000				; Set "round over" bit
	; BL display_end_of_round

	STR r5, [r4]			; Store the new general info into memory

	BL illuminate_winner				; Light LED for winner

	PUSH {r0, r1}

	LDR r0, ptr_to_score_string

	MOV r1, r6

	BL int2string

	LDR r0, ptr_to_update_score_1

	BL output_ansi_string

	LDR r0, ptr_to_score_string

	BL output_string

	;BL erase_left_paddle_srt

	;BL erase_right_paddle_srt

	POP {r0, r1}

	POP {r4-r12, lr}

	MOV pc, lr




pause_game:						; Sets the "paused" bit in general game info

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

	LDR r4, ptr_to_general		; Load general game data pointer in r4
	LDR r5, [r4]				; Load contents of general into r5
	ORR r5, r5, #0x4000000		; Set the "paused" bit (Bit 26)
	STR r5, [r4]				; Update general game info

	BL display_pause_menu

	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before


unpause_game:					; Clears the "paused" bit in general game info

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

	BL remove_menu

	LDR r4, ptr_to_general		; Load general game data pointer in r4
	LDR r5, [r4]				; Load contents of general into r5
	BFC r5, #26, #1				; Clear the "paused" bit (Bit 26)
	STR r5, [r4]				; Update general game info

	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before





ALICE_interrupt_init:

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

	MOV r4, #0x7000				; Put GPIO Port D Base Address in r4 (LSB)
	MOVT r4, #0x4000			; GPIO Port D Base Address (MSB)

								; Enable edge sensitivity
	LDR r5, [r4, #0x404]		; Load contents of the GPIO Interrupt Sense Register into r5
	BFC r5, #0, #4				; Clear bits 0-3 in the GPIOIS to enable Edge Sensitivity
	STR r5, [r4, #0x404]		; Transmit updated information to GPIOIS

								; Allow GPIO Event Control Register to control Edge Triggering
	LDR r5, [r4, #0x408]		; Load contents of the GPIO Interrupt Both Edges Register into r5
	BFC r5, #0, #4				; Clear bits 0-3 in the GPIOIBE to allow the GPIOIEV to assume control
	STR r5, [r4, #0x408]		; Transmit updated information to GPIOIBE

								; Enable Falling Edge Triggering in the GPIO Interrupt Event Register
	LDR r5, [r4, #0x40C]		; Load contents of the GPIOIEV into r5
	MOV r7, #0xF
	BFI r5, r7, #0, #4
	;BFC r5, #0, #4				; Clear bits 0-3 in the GPIOIS to enable Edge Sensitivity
	STR r5, [r4, #0x40C]		; Transmit updated information to GPIOIS

								; Enable Interrupts in the GPIO Interrupt Mask Register
	LDRB r5, [r4, #0x410]		; Load contents of the GPIOIM into r5
	ORR r5, r5, #0xF			; Set bits 0-3 in the GPIOIM to enable Edge Sensitivity
	STRB r5, [r4, #0x410]		; Transmit updated information to GPIOISR

								; Allow GPIO Port D to interrupt in the Interrupt 0-31 Set Enable (EN0)
	MOV r4, #0xE100				; Copy EN0 base address (LSB) with offset
	MOVT r4, #0xE000			; EN0 base address (MSB)
	LDR r5, [r4]				; Load information from EN0 into r5
	ORR	r5, r5, #8				; Set 3rd bit to enable interrupts from GPIO Port D
	STR r5, [r4]				; Transmit updated information to EN0

	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return






choose_game_length:				; Based on the ALICE button pressed, initialize game length
								; SW5 - 7 points | SW4 - 9 points | SW3 - 11 points | SW2 - Unlimited

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

	LDR r4, ptr_to_general		; Load general info pointer into r4
	LDR r5, [r4]				; Load general game info into r5
	BFC r5, #16, #4				; Clear "Game Threshold" bits from general info (bits 16-19)

	MOV r6, #0x7000				; Retrieve ALICE Button GPIO Data
	MOVT r6, #0x4000			; Move Port D's address into r6
	LDRB r7, [r6,#0x3FC]		; Load Port D's data register into r7

	TST r2, #0x1				; Check if SW5 was pressed
	BNE seven_point_game		; If so, set seven point game
	TST r2, #0x2				; Check if SW4 was pressed
	BNE nine_point_game			; If so, set nine point game
	TST r2, #0x4				; Check if SW3 was pressed
	BNE eleven_point_game		; If so, set eleven point game
	TST r2, #0x8				; Check if SW2 was pressed
	BNE unlimited_game			; If so, set unlimited point game

seven_point_game:

	MOV r8, #7					; Store seven (point threshold) in r8
	BFI r5, r8, #16, #4			; Insert point threshold into r5
	STR r5, [r4]				; Store updated general game info
	B exit_choose_game_length	; Exit subroutine

nine_point_game:

	MOV r8, #9					; Store nine (point threshold) in r8
	BFI r5, r8, #16, #4			; Insert point threshold into r5
	STR r5, [r4]				; Store updated general game info
	B exit_choose_game_length	; Exit subroutine

eleven_point_game:

	MOV r8, #11					; Store eleven (point threshold) in r8
	BFI r5, r8, #16, #4			; Insert point threshold into r5
	STR r5, [r4]				; Store updated general game info
	B exit_choose_game_length	; Exit subroutine

unlimited_game:

	STR r5, [r4]				; Store updated general game info (point threshold = 0)
								; Bits already cleared from before

exit_choose_game_length:
	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before





illuminate_winner:				; Illuminate the Tiva RGB LED with the latest winner's color
								; Also triggers on penalty

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

								; Retrieve TIVA LED information & prepare for illumination
	MOV r4, #0x53FC				; Copy Port F GPIODATA Address (LSB) into r4 (with offset)
	MOVT r4, #0x4002			; Port F GPIODATA (MSB)
	LDRB r5, [r4]				; Load GPIODATA info into r5
	BFC r5, #1, #3				; Clear RGB illumination bits (Bits 1-3)

	LDR r9, ptr_to_general		; Load game info address into r9
	LDR r6, [r9]				; Load game info into r6
	TST r6, #0x10000000			; Test Bit 28 (Player 1 won)
	BNE illuminate_player1		;
	TST r6, #0x20000000			; Test Bit 29 (Player 2 won)
	BNE illuminate_player2		;
	BEQ exit_illuminate_winner 	; If no winner, exit

illuminate_player1:

	LDR r10, ptr_to_player1info	; Load player 1's info (address) into r10
	LDR r7, [r10]				; Load player 1's info into r7
	UBFX r8, r7, #13, #3		; Extract bits 13-15 from r7 into r8
	ORR r5, r5, r8, LSL #1		; Shift r8 left 1 bit and use to set RGB bits
	STRB r5, [r4]				; Store updated RGB LED info in GPIO

	B exit_illuminate_winner

illuminate_player2:

	LDR r10, ptr_to_player2info	; Load player 1's info into r10
	LDR r7, [r10]				; Load player 1's info into r7
	UBFX r8, r7, #13, #3		; Extract bits 13-15 from r7 into r8
	ORR r5, r5, r8, LSL #1		; Shift r8 left 1 bit and use to set RGB bits
	STRB r5, [r4]				; Store updated RGB LED info in GPIO

exit_illuminate_winner:
	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before





randomInt:						; Loads a random (timer-based) integer into r0
								; The random number is based on the GameTic value (Timer 1A)

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

	MOV r4, #0x1050				; Store Timer 1 address (LSB) with GPTMTAV r4
	MOVT r4, #0x4003			; Timer 1 address (MSB) (it means General Purpose Timer A Value)
	LDRB r0, [r4]				; Stores random value in r0

	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before





reset_speed:					; Reset game speed to 30FPS

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

								; Clear current game speed
	LDR r4, ptr_to_general		; Load general game info address into r4
	LDR r5, [r4]				; Load general game info into r5
	BFC r5, #23, #3				; Clear game ball speed (bits 23-25 in general)
	STR r5, [r4]				; Store information in memory

	MOV r7, #0x1000				; Store Timer 1 base address (LSB) with GPTMTAILR offset in r7
	MOVT r7, #0x4003			; (MSB) General Purpose Timer (1)A Interval Load Register

								; Disable GameTic timer for modification
	LDRB r8, [r7, #0xC]			; Load contents of GPTMCTL (with offset) into r6
	BFC r8, #0, #1				; Clear the Timer 1A Enable bit (0th Bit)
	STRB r8, [r7, #0xC]			; Transmit masked data to disable Timer 1A

								; Set up GameTic Interval Period (of 30Hz)
	MOV r6, #0x8235				; Store period (of 533,333(/2^4)) Clock Tics) in r6
	LSL r6, r6, #4				; Multiply r6 * 2^4 for product of 533,328 (period = 30Hz)
	STR r6, [r7, #0x28]			; Transmit period to GPTMCTL (with offset)

								; Re-enable GameTic timer
	LDRB r8, [r7, #0xC]			; Load contents of GPTMTAILR (with offset) into r6
	ORR r8, r8, #0x1			; Unmask contents of r5 to set the Timer A Enable bit (0th Bit)
	STRB r8, [r7, #0xC]			; Transmit masked data to enable Timer 1A

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

	MOV r7, #0x1000				; Store Timer 1 base address (LSB) with GPTMTAILR offset in r7
	MOVT r7, #0x4003			; (MSB) General Purpose Timer (1)A Interval Load Register
								; Re-enable GameTic timer
	LDRB r8, [r7, #0xC]			; Load contents of GPTMCTL (with offset) into r6
	ORR r8, r8, #0x1			; Unmask contents of r5 to set the Timer A Enable bit (0th Bit)
	STRB r8, [r7, #0xC]			; Transmit masked data to enable Timer 1A

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





loop:
	B loop						; Loop indefinitely





deluminate_powerup:				; Choose which lights to illuminate based on powerup state/time expired
								; Called by GameClock_Timer_Handler

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

								; Check if a player is powered up
	LDR r4, ptr_to_player1info	; Load Player 1's info (address) to r4
	LDR r5, [r4]				; Load Player 1's game info to r5
	TST r5, #0x20				; Retrieve bit 5 ("powerup state") and place in r6
	BNE check_powerup_LEDs		; If player 1 is powered up, check timer

	LDR r4, ptr_to_player2info	; Load Player 2's info (address) to r4
	LDR r5, [r4]				; Load Player 2's game info to r5
	TST r5, #0x20				; Check if 5th bit ("powerup state") is set
	BNE check_powerup_LEDs		; If player 2 is powered up, check timer

	B no_powerup_LEDs			; If neither player is powered up, branch

check_powerup_LEDs:

	MOV r6, #0x53FC				; Copy Port B GPIODATA Address (LSB) into r6 (with offset)
	MOVT r6, #0x4000			; Port B GPIODATA (MSB)
	LDRB r7, [r6]				; Load GPIODATA info into r7

	LDR r10, ptr_to_poweruptime	; Retrieve powerup time info (time activated) (address)
	LDR r8, [r10]				; Retrieve powerup time info
	LDR r11, ptr_to_timer		; Retrieve current time (address)
	LDR r9, [r11]				; Retrieve current time
	ADD r8, r8, #12
	CMP r9, r8					; Have 12 seconds elapsed? (timer >= power up time + 12)?
	BGE	powerup_LEDs_timeout	; If so, remove powerup and turn off lights
	SUB	r8, r8, #3
	CMP r9, r8					; Have 9 seconds elapsed? (timer >= power up time + 9)?
	BGE	one_powerup_LED			; If so, turn off all but one light
	SUB	r8, r8, #3
	CMP r9, r8					; Have 6 seconds elapsed? (timer >= power up time + 6)?
	BGE	two_powerup_LEDs		; If so, turn off half of the lights
	SUB	r8, r8, #3
	CMP r9, r8					; Have 3 seconds elapsed? (timer >= power up time + 3)?
	BGE	three_powerup_LEDs		; If so, turn off the first light
	BLT four_powerup_LEDs		; If the powerup is fresh (timer < power up time + 3), turn on all lights

four_powerup_LEDs:				; Illuminate all four ALICE LEDs

	ORR r7, r7, #0xF			; Set bits 0-3 in r7 to enable LEDs
	STRB r7, [r6]				; Store information in GPIO to illuminate LEDs
	B exit_deluminate_powerup	; Exit subroutine

three_powerup_LEDs:

	BFC r7, #0, #4				; Clear bits 0-3 to disable LEDs
	ORR r7, r7, #0xE			; Set bits 1-3 in r7 to enable LEDs
	STRB r7, [r6]				; Store information in GPIO to illuminate LEDs
	B exit_deluminate_powerup	; Exit subroutine

two_powerup_LEDs:

	BFC r7, #0, #4				; Clear bits 0-3 to disable LEDs
	ORR r7, r7, #0xC			; Set bits 2-3 in r7 to enable LEDs
	STRB r7, [r6]				; Store information in GPIO to illuminate LEDs
	B exit_deluminate_powerup	; Exit subroutine

one_powerup_LED:

	BFC r7, #0, #4				; Clear bits 0-3 to disable LEDs
	ORR r7, r7, #0x8			; Set the 3rd bit in r7 to enable one LED
	STRB r7, [r6]				; Store information in GPIO to illuminate LEDs
	B exit_deluminate_powerup	; Exit subroutine

powerup_LEDs_timeout:			; If time has expired on the powerup, update info to allow for a new one

	BFC r5, #5, #1				; Clear triggering player's powerup state bit (5th bit)

no_powerup_LEDs:				; Deluminate all ALICE LEDs

	BFC r7, #0, #4				; Clear bits 0-3 in r7 to disable LEDs
	STRB r7, [r6]				; Store information in GPIO to deactivate LEDS

exit_deluminate_powerup:

	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before





collect_powerup:				; When the ball collides with a powerup, update game info
								; and double the size of the collecting player's paddle

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

	LDR r4, ptr_to_timer		; Load Game Clock address to r4
	LDR r5, [r4]				; Load game time elapsed (seconds) to r5
	LDR r6, ptr_to_poweruptime	; Load Power Up Time address to r6
	STR r5, [r6]				; Store "Time Powerup Acquired" to memory ("poweruptime")

	LDR r7, ptr_to_powerup_countdown	; Load powerup respawn timer in r7
	BL randomInt						; Put a random integer in r0
	MOV r1, #13							; Copy divisor (13) into r0
	BL division							; Get random value 0-13 (modulo)
	ADD r5, r5, r1						; Add random value into r5
	ADD r5, r5, #14						; Add 14 to r5 for value of 14-27 (12 + 2-15)
	STR r5, [r7]						; Store value in powerup_countdown

								; Double paddle size
								; IMPLEMENT THIS

								; Check ball direction (L/R) to determine whose powerup it is
	LDR r4, ptr_to_general		; Load "general" memory address into r4
	LDR r5, [r4]				; Load "general" data into r5
	UBFX r6, r5, #13, #3		; Retrieve "Ball Direction" bits (13-15) from r5

								; CHECK THIS WHEN TESTING
	TST r6, #0x01				; If ball is traveling left, then award the powerup to player 2
	BNE p2_powerup
	LDR	r7, ptr_to_player1info	; Else, award the powerup to player 1
	LDR r8, [r7]				; Retrieve player 1's info
	ORR r8, r8, #0x20			; Set player 1's "powerup state" bit to 1
	STR r8, [r7]				; Store updated info

	B exit_collect_powerup		; Skip next few lines

p2_powerup:

	LDR	r7, ptr_to_player2info	; Award the powerup to player 2
	LDR r8, [r7]				; Retrieve player 2's info
	ORR r8, r8, #0x20			; Set player 2's "powerup state" bit (5th bit) to 1
	STR r8, [r7]				; Store updated info

exit_collect_powerup:

	LDR r4, ptr_to_powerupinfo	; Load powerupinfo address
	LDR r5, [r4]				; Load powerupinfo into r5
	BFC r5, #13, #1				; Clear "powerup present" bit from powerupinfo

								; Illuminate ALICE LEDs
	MOV r4, #0x53FC				; Copy Port B GPIODATA Address (LSB) into r4 (with offset)
	MOVT r4, #0x4000			; Port B GPIODATA (MSB)
	LDRB r5, [r4]				; Load GPIODATA info into r5
	ORR r5, r5, #0xF			; Set bits 0-3 in r5 to enable LEDs
	STRB r5, [r4]				; Store information in GPIO to illuminate LEDs

	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before





spawn_powerup:

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

								; Check if powerup is present. If so, exit
	LDR r4, ptr_to_powerupinfo	; Load powerupinfo pointer into r4
	LDR r5, [r4]				; Load powerup info into r5
	TST r5, #0x20				; Test "powerup present" bit (Bit 13)
	BNE exit_spawn_powerup		; If set, exit

										; Check if powerup_countdown has passed. If not, exit
	LDR r6, ptr_to_powerup_countdown	; Load powerup_countdown pointer into r6
	LDR r7, [r6]						; Load contents of powerup_countdown into r7
	LDR r8, ptr_to_timer				; Load timer pointer into r8
	LDR r9, [r8]						; Load current time into r9
	CMP r9, r7							; Compare current time vs. powerup_countdown
	BGT	exit_spawn_powerup				; If powerup_countdown has not yet passed, exit

								; Spawn powerup randomly
	BL randomInt				; Choose random X (21-60)
	MOV r1, #40					; Store divisor in r1 (r1=40)
	BL division					; Get the result of r0 % r1 (stored in r1)
	ADD r1, r1, #21				; Add 21 to r1 for range of 21-60
	BFI r5, r1, #0, #8			; Insert r1 into powerup info (Bits 0-7)

								; Choose random Y (5-20)
	BL randomInt				; Get a random integer in r0
	MOV r1, #16					; Store divisor in r1 (r1 = 16)
	BL division					; Get the result of r0 % r1 (stored in r1)
	ADD r1, r1, #5				; Add 5 to r1 for range of 5-20
	BFI r5, r1, #8, #5			; Insert r1 into general info (Bits 8-12)

	ORR r5, #0x20				; Set "Powerup Presence" Bit (Bit 13)

								; Draw powerup on board
								; IMPLEMENT THIS

exit_spawn_powerup:
	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before





do_the_LED_dance:				; Illuminate ALICE LEDs for the game's winner; called by GameTic_Timer_Handler

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

								; Check if game has been won
	LDR r7, ptr_to_general		; Load general game info (address) into r7
	LDR r4, [r7]				; Load general info into r4
	TST r4, #0x8000000			; Test bit 27
	BEQ exit_LED_dance			; If game is not over, do not dance
	TST r4, #0x30000000			; Test bits 28 & 29 (player 1 & 2 won, respectively)
	BEQ exit_LED_dance			; If no winner, do not dance

								; Prepare for GPIO access
	MOV r4, #0x53FC				; Copy Port B GPIODATA Address (LSB) into r4 (with offset)
	MOVT r4, #0x4000			; Port B GPIODATA (MSB)
	LDRB r5, [r4]				; Load GPIODATA info into r5

	LDR r8, ptr_to_frame_count	; Check the current GameTic
	LDR r6, [r8]				; Retrieve GameTic info
	TST r6, #1					; If odd, illuminate
	BEQ LED_dance_darken		; If even, darken

								; Illuminate ALICE LEDs
	ORR r5, r5, #0xF			; Set bits 0-3 in r5 to enable LEDs
	STRB r5, [r4]				; Store information in GPIO to illuminate LEDs

	B exit_LED_dance

LED_dance_darken:				; Darken ALICE LEDs

	BFC r5, #0, #4				; Clear bits 0-3 in r5 to enable LEDs
	STRB r5, [r4]				; Store information in GPIO to illuminate LEDs

exit_LED_dance:

	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before





clear_RGB_LED:					; When a new round starts, clear LED

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

								; Deluminate TIVA LED
	MOV r4, #0x53FC				; Copy Port F GPIODATA Address (LSB) into r4 (with offset)
	MOVT r4, #0x4002			; Port F GPIODATA (MSB)
	LDRB r5, [r4]				; Load GPIODATA info into r5
	BFC r5, #1, #3				; Clear bits 1-3 in r5 to disable LED
	STRB r5, [r4]				; Store information in GPIO to deactivate LED

	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before





timer_init:						; Initialize Timers 0A & 1A for seconds & frames/tics, respectively

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

rgb_led_color_to_escape_digit:

	CMP r0, #1					; Number 1, red in both schemes
	BEQ exit_rlcted

	CMP r0, #2					; Number 2, blue in rgb
	IT EQ
	ADDEQ r0, r0, #2			; Make r0 4
	BEQ exit_rlcted

	CMP r0, #3					; Number 3, purple (magenta) in rgb
	IT EQ
	ADDEQ r0, r0, #2			; Make r0 5
	BEQ exit_rlcted

	CMP r0, #4					; Number 4, green in rgb
	IT EQ
	SUBEQ r0, r0, #2				; Make r0 2
	BEQ exit_rlcted

	CMP r0, #5					; Number 5, yellow in rgb
	IT EQ
	SUBEQ r0, r0, #2			; Make r0 3
	BEQ exit_rlcted

	CMP r0, #6					; Number 6, cyan in both
	BEQ exit_rlcted

	; The last color available is white
	MOV r0, #7

exit_rlcted:

	ADD r0, r0, #0x10				; Conver the digit to the escape character

	MOV pc, lr



clear_ALICE_LEDs:					; When a new round starts, clear LED

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

								; Deluminate TIVA LED
	MOV r4, #0x53FC				; Copy Port D GPIODATA Address (LSB) into r4 (with offset)
	MOVT r4, #0x4000			; Port D GPIODATA (MSB)
	LDRB r5, [r4]				; Load GPIODATA info into r5
	BFC r5, #0, #4				; Clear bits 0-3 in r5 to disable LEDs
	STRB r5, [r4]				; Store information in GPIO to deactivate LED

	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before

erase_left_paddle_srt:

	PUSH {lr}

	LDR r0, ptr_to_erase_left_paddle

	BL output_ansi_string

	MOV r1, #6

erase_left_loop:

	LDR r0, ptr_to_draw_paddle

	BL output_string

	SUB r1, r1, #1

	CMP r1, #0

	BNE erase_left_loop

	POP {lr}

	MOV pc, lr

erase_right_paddle_srt:

	PUSH {lr}

	LDR r0, ptr_to_erase_right_paddle

	BL output_ansi_string

	MOV r1, #6

erase_right_loop:

	LDR r0, ptr_to_draw_paddle

	BL output_string

	SUB r1, r1, #1

	CMP r1, #0

	BNE erase_right_loop

	POP {lr}

	MOV pc, lr


new_subroutine:					; Placeholder so I can copy/paste spilling & restoring registers

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return to what you were doing before

	.end
