.data
	.global general
	.global player1_info
	.global player2_info
	.global move_cursor
	.global color
	.global draw_paddle
	.global board

.text


	.global UART0_Handler

	.global simple_read_character
	.global int2string
	.global output_string
	.global output_ansi_string
	.global rgb_led_color_to_escape_digit
	.global display_pause_menu
	.global remove_menu
	.global display_new_game_menu
	.global init_new_game
	.global init_new_round
	.global illuminate_winner


ptr_to_general:		.word general
ptr_to_player1info:	.word player1_info
ptr_to_player2info:	.word player2_info
ptr_to_move_cursor:	.word move_cursor
ptr_to_color:		.word color
ptr_to_draw_paddle:	.word draw_paddle
ptr_to_board:		.word board



UART0_Handler:

	PUSH {r4-r12,lr}			; Spill/Save registers to stack

	MOV r4, #0xC044				; Put UART0 Base Address (with offset) in r4 (LSB)
	MOVT r4, #0x4000			; (MSB)
	LDRB r5, [r4]				; Load data from UARTCIR in r5
	MOV r6, #0x10				; Prepare r6 for masking (LSB)
	ORR r5, r5, r6				; Set 4th bit (RXIC) in r5 (XXX1 XXXX)
	STRB r5, [r4]				; Store value from r5 in UARTCIR

	BL simple_read_character

								; Check if game is over/paused. If so, do nothing
	LDR r4, ptr_to_general		; Load general game data pointer in r4
	LDR r5, [r4]				; Load contents of general into r5

	TST r5, #0x40000000			; Test "round over" bit (Bit 30)
	BNE init_new_round			; If round is over, any key starts next round

	TST r5, #0x4000000			; Check the paused bit (Bit 26)
	BNE check_for_reset			; Check if the game should reset

	CMP r0, #0x32				; If character is "2", act as SW2
	BEQ init_new_game			; Initialize Unlimited game

	CMP r0, #0x33				; If character is "3", act as SW3
	BEQ init_new_game			; Initialize 11-point game

	CMP r0, #0x34				; If character is "4", act as SW4
	BEQ init_new_game			; Initialize 9-point game

	CMP r0, #0x35				; If character is "5", act as SW5
	BEQ init_new_game			; Initialize 7-point game

	TST r5, #0x8000000			; Check the game over bit (26)
	BNE exit_UART_handler		; If bit is set, do nothing

	CMP r0, #0x77				; If the character is "w"
	BEQ move_left_up

	CMP r0, #0x73				; If the character is "s"
	BEQ move_left_down

	CMP r0, #0x70				; If the character is "p"
	BEQ move_right_up

	CMP r0, #0x3B				; If the character is ";"
	BEQ move_right_down

	B exit_UART_handler

move_left_down:

	UBFX r4, r5, #0, #8	; Extract the ball's x position from general

	CMP r4, #10
	IT GT
	BLGT check_left_penalty

	LDR r0, ptr_to_player1info

	LDR r4, [r0]		; Load player 1 info into r4

	MOV r5, #4		; Set r5 (paddle width) = 4

	MOV r6, #23		; Set r6 (lowest legal paddle position) = 23


	TST r4, #0x20		; Test player 1's powerup bit

	ITT NE

	ADDNE r5, r5, #4	; If the powerup bit is set, make the paddle
				; 4 pixels wider

	SUBNE r6, r6, #4	; If the powerup bit is set, move the legal paddle
				; position 4 more pixels from the bottom

	UBFX r7, r4, #0, #5		; Extract the paddle position from player1_info
	UBFX r9, r4, #13, #3	; Extract the paddle color from player_1_info

	MOV r8, r7		; Copy the old paddle position to r8

	CMP r7, r6

	IT LT

	ADDLT r7, r7, #1	; If the paddle position is less than (above)
				; the lowest legal position, increment the paddle
				; position (move it down)

	BFI r4, r7, #0, #5	; Insert the new paddle position into player1_info

	STR r4, [r0]		; Store the new version of player1_info in memory

	B update_left_paddle

move_left_up:

	UBFX r4, r5, #0, #8	; Extract the ball's x position from general

	CMP r4, #10
	IT GT
	BLGT check_left_penalty

	LDR r0, ptr_to_player1info

	LDR r4, [r0]            ; Load player 1 info into r4

	UBFX r7, r4, #0, #5		; Extract the paddle position from player1_info
	UBFX r9, r4, #13, #3	; Extract the paddle color from player_1_info

	MOV r8, r7		; Copy the old paddle position into r8 (so we still have it
				; when we want to redraw the paddle)

	CMP r7, #3

	IT GT

	SUBGT r7, r7, #1        ; If the paddle position is greater than (below)
                                ; the highest legal position, decrement the paddle
                                ; position (move it up)

	BFI r4, r7, #0, #5      ; Insert the new paddle position into player1_info

	STR r4, [r0]            ; Store the new version of player1_info in memory

update_left_paddle:


	; Start by drawing a black paddle over the old one

	LDR r0, ptr_to_move_cursor

	ADD r0, r0, #2		; Add 2 to the pointer to get past the escape characters

	MOV r1, r8		; Copy the old paddle position into r1 (for the int2string call)

	BL int2string		; Note: because of the way we implemented int2string, r0 will be returned
						; as the end of the string, which is exactly what we need it to be so we
						; can continue writing this string

	MOV r1, #0x3B		; Store a ";" in r1

	STRB r1, [r0]

	ADD r0, r0, #1

	MOV r1, #0x32		; Store "2" in r1

	STRB r1, [r0]

	ADD r0, r0, #1

	MOV r1, #0x48		; Store "H" in r1

	STRB r1, [r0]

	ADD r0, r0, #1

	MOV r1, #0		; Null terminate the string

	STRB r1, [r0]

	LDR r0, ptr_to_move_cursor

	BL output_string

	LDR r0, ptr_to_color

	MOV r1, #0x10		; Move our code for black into r1

	STRB r1, [r0]

	BL output_ansi_string

	LDR r0, ptr_to_draw_paddle

	BL output_string

	TST r4, #0x20

	LDR r0, ptr_to_draw_paddle

	IT NE

	BLNE output_string	; If the powerup bit is set, draw a second paddle




	; Draw the new paddle

	LDR r0, ptr_to_move_cursor

	ADD r0, r0, #2		; Add 2 to the pointer to get past the escape characters

	MOV r1, r7		; Copy the new paddle position into r1 (for the int2string call)

	BL int2string		; Note: because of the way we implemented int2string, r0 will be returned
						; as the end of the string, which is exactly what we need it to be so we
						; can continue writing this string

	MOV r1, #0x3B		; Store a ";" in r1

	STRB r1, [r0], #1

	MOV r1, #0x32		; Store "2" in r1

	STRB r1, [r0], #1

	MOV r1, #0x48		; Store "H" in r1

	STRB r1, [r0], #1

	MOV r1, #0		; Null terminate the string

	STRB r1, [r0]

	LDR r0, ptr_to_move_cursor

	BL output_string

	LDR r0, ptr_to_color

	PUSH {r0}

	MOV r0, r9

	BL rgb_led_color_to_escape_digit

	MOV r1, r0

	POP {r0}

	STRB r1, [r0]

	BL output_ansi_string

	LDR r0, ptr_to_draw_paddle

	BL output_string

	TST r4, #0x20

	LDR r0, ptr_to_draw_paddle

	IT NE

	BLNE output_string	; If the powerup bit is set, draw a second paddle

	B exit_UART_handler


move_right_down:

	UBFX r4, r5, #0, #8	; Extract the ball's x position from general

	CMP r4, #71
	IT LT
	BLLT check_right_penalty

	LDR r0, ptr_to_player2info

	LDR r4, [r0]		; Load player 2 info into r4

	MOV r5, #4		; Set r5 (paddle width) = 4

	MOV r6, #23		; Set r6 (lowest legal paddle position) = 23

	TST r4, #0x20		; Test player 2's powerup bit

	ITT NE

	ADDNE r5, r5, #4	; If the powerup bit is set, make the paddle
				; 4 pixels wider

	SUBNE r6, r6, #4	; If the powerup bit is set, move the legal paddle
				; position 4 more pixels from the bottom

	UBFX r7, r4, #0, #5		; Extract the paddle position from player2_info
	UBFX r9, r4, #13, #3	; Extract the paddle color from player_2_info

	MOV r8, r7		; Copy the old paddle position into r8

	CMP r7, r6

	IT LT

	ADDLT r7, r7, #1	; If the paddle position is less than (above)
				; the lowest legal position, increment the paddle
				; position (move it down)

	BFI r4, r7, #0, #5	; Insert the new paddle position into player2_info

	STR r4, [r0]		; Store the new version of player2_info in memory

	B update_right_paddle

move_right_up:

	UBFX r4, r5, #0, #8	; Extract the ball's x position from general

	CMP r4, #71
	IT LT
	BLLT check_right_penalty

	LDR r0, ptr_to_player2info

	LDR r4, [r0]		; Load player 2 info into r4

	UBFX r7, r4, #0, #5		; Extract the paddle position from player2_info
	UBFX r9, r4, #13, #3	; Extract the paddle color from player_2_info

	MOV r8, r7		; Copy the old paddle position into r8

	CMP r7, #3

	IT GT

	SUBGT r7, r7, #1	; If the paddle position is greater than (below)
				; the highest legal position, decrement the paddle
				; position (move it up)

	BFI r4, r7, #0, #5	; Insert the new paddle position into player2_info

	STR r4, [r0]		; Store the new version of player2_info in memory



update_right_paddle:

; Start by drawing a black paddle over the old one

	LDR r0, ptr_to_move_cursor

	ADD r0, r0, #2		; Add 2 to the pointer to get past the escape characters

	MOV r1, r8		; Copy the old paddle position into r1 (for the int2string call)

	BL int2string		; Note: because of the way we implemented int2string, r0 will be returned
						; as the end of the string, which is exactly what we need it to be so we
						; can continue writing this string

	MOV r1, #0x3B		; Store a ";" in r1

	STRB r1, [r0]

	ADD r0, r0, #1

	MOV r1, #0x38		; Store "8" in r1

	STRB r1, [r0]

	ADD r0, r0, #1

	MOV r1, #0x31		; Store "1" in r1

	STRB r1, [r0]

	ADD r0, r0, #1

	MOV r1, #0x48		; Store "H" in r1

	STRB r1, [r0]

	ADD r0, r0, #1

	MOV r1, #0		; Null terminate the string

	STRB r1, [r0]

	LDR r0, ptr_to_move_cursor

	BL output_string

	LDR r0, ptr_to_color

	MOV r1, #0x10		; Move our code for black into r1

	STRB r1, [r0]

	BL output_ansi_string

	LDR r0, ptr_to_draw_paddle

	BL output_string

	TST r4, #0x20

	LDR r0, ptr_to_draw_paddle

	IT NE

	BLNE output_string	; If the powerup bit is set, draw a second paddle




	; Draw the new paddle

	LDR r0, ptr_to_move_cursor

	ADD r0, r0, #2		; Add 2 to the pointer to get past the escape characters

	MOV r1, r7		; Copy the new paddle position into r1 (for the int2string call)

	BL int2string		; Note: because of the way we implemented int2string, r0 will be returned
						; as the end of the string, which is exactly what we need it to be so we
						; can continue writing this string

	MOV r1, #0x3B		; Store a ";" in r1

	STRB r1, [r0], #1

	MOV r1, #0x38		; Store "8" in r1

	STRB r1, [r0], #1

	MOV r1, #0x31		; Store "1" in r1

	STRB r1, [r0], #1

	MOV r1, #0x48		; Store "H" in r1

	STRB r1, [r0], #1

	MOV r1, #0		; Null terminate the string

	STRB r1, [r0]

	LDR r0, ptr_to_move_cursor

	BL output_string

	LDR r0, ptr_to_color

	PUSH {r0}

	MOV r0, r9

	BL rgb_led_color_to_escape_digit

	MOV r1, r0

	POP {r0}

	STRB r1, [r0]

	BL output_ansi_string

	LDR r0, ptr_to_draw_paddle

	BL output_string

	TST r4, #0x20

	LDR r0, ptr_to_draw_paddle

	IT NE

	BLNE output_string	; If the powerup bit is set, draw a second paddle

	B exit_UART_handler

check_for_reset:

	; Here, the game is paused

	CMP r0, #0x72		; Check if the key pressed is "r"

	LDR r0, ptr_to_board

	; Reset the game somehow
	ITT EQ
	BLEQ output_ansi_string
	BLEQ init_new_game 	; ???

	; Fall through to exit_UART_handler

exit_UART_handler:

	POP {r4-r12,lr}				; Restore registers from stack
	BX lr						; Return to what you were doing before



check_left_penalty:

	;TST r5, #0x2000		; Check if the ball ks moving right
	;BNE left_penalty

								; Penalty check; is ball traveling left? (Ball direction bit == 1 is correct)
	TST r5, #0x2000				; Test ball direction (L/R) bit (Bit 13) (If bit is set, no penalty)
	BNE exit_check_left_penalty	; No move_left_down_penalty
	UBFX r6, r5, #0, #8			; Extract "Ball Position X" bits (Bits 0-7) from r5
	CMP r6, #10					; Is ball within the grace range? (10 spaces of left)
	BLE exit_check_left_penalty	; If so, no penalty

								; PENALTY ZONE
	ORR r5, r5, #0x60000000		; Set "round over" & "p2 won" bits in r5 (Bits 30 & 29)

	LDR r6, ptr_to_player1info	; Decrease p1 score
	LDR r7, [r6]				; Load player 1 info into r7
	UBFX r8, r7, #6, #7			; Extract Player Score bits (6-13) into r8
	CMP r8, #0					; Is score > 0?
	IT GT
	SUBGT r8, r8, #1			; Decrease p1's score by 1
	BFI r7, r8, #6, #7			; Insert new score into r7
	STR r7, [r6]				; Update p1 score

	LDR r6, ptr_to_player2info	; Increase p2 score
	LDR r7, [r6]				; Load player 2 info into r7
	UBFX r8, r7, #6, #7			; Extract Player Score bits (6-13) into r8
	ADD r8, r8, #1				; Increase p2's score by 1
	BFI r7, r8, #6, #7			; Insert new score into r7
	STR r7, [r6]				; Update p2 score

	STR r5, [r4]				; Update general info

	BL illuminate_winner

	B exit_UART_handler			; Now, exit handler

exit_check_left_penalty:
	MOV pc, lr


check_right_penalty:

	TST r5, #0x2000		; Check if the ball ks moving right

	;BEQ right_penalty

exit_check_right_penalty:
	MOV pc, lr
	.end
