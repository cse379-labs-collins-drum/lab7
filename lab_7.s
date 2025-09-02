	.data

	.global board

board:	.string 0xC, 0x18,      "          0                          Timer: 0                         0           ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x19, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ",0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x10, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, " ", 0x19, "                                                                                ", 0x18, " ", 0x10, 0xA, 0xD
				.string 0x18, "                                                                                  ", 0x10,0

draw_paddle:			.string 27, "[1D", 27, "[1B ", 27, "[1D", 27, "[1B ", 27, "[1D", 27, "[1B ", 27, "[1D", 27, "[1B ", 0
draw_pixel:				.string " ", 0
color:					.string 0x10, 0


	.text
	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global uart_init
	.global gpio_btn_and_LED_init
	.global UART0_Handler
	.global Switch_Handler
	.global timer_init
	.global Timer_Handler
	.global lab7
	.global output_character
	.global simple_read_character
	.global output_string
	.global int2string
	.global board
	.global score
	.global score_text
	.global game_state
	.global wait
	.global output_ansi_string
	.global init_PlayClock
	.global init_GameTic
	.global ALICE_interrupt_init
	.global timer_init
	.global display_new_game_menu




board_ptr:			.word board
paddle_ptr:			.word draw_paddle
color_ptr:			.word color



lab7:
	PUSH {r4-r12,lr}			; Save registers to stack

	BL uart_init

	LDR r0, board_ptr

	BL output_ansi_string

	BL uart_interrupt_init
	BL gpio_btn_and_LED_init
	BL gpio_interrupt_init
	BL ALICE_interrupt_init
	BL timer_init

	BL init_PlayClock
	BL init_GameTic

	BL display_new_game_menu

loop:
	B loop

exit_lab7:
	POP {r4-r12,lr}				; Restore registers from stack
	MOV pc, lr					; Return


.end
