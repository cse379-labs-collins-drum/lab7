	.data

pause_text:		.string 0x18, 27,  "[8;22H                                        "
			.string 0x18, 27,  "[9;22H              PAUSED  GAME              "
			.string 0x18, 27, "[10;22H                                        "
			.string 0x18, 27, "[11;22H                                        "
			.string 0x18, 27, "[12;22H                                        "
			.string 0x18, 27, "[13;22H          Press SW1 to unpause          "
			.string 0x18, 27, "[14;22H               the round                "
			.string 0x18, 27, "[15;22H                                        "
			.string 0x18, 27, "[16;22H                                        "
			.string 0x18, 27, "[17;22H          Press the 'r' key to          "
			.string 0x18, 27, "[18;22H            restart the game            "
			.string 0x18, 27, "[19;22H                                        "
			.string 0x18, 27, "[20;22H                                        "
			.string 0x18, 27, "[21;22H                                        ", 0


select_game_length:	.string 0x18, 27,  "[8;22H                                        "
			.string 0x18, 27,  "[9;22H                NEW GAME                "
			.string 0x18, 27, "[10;22H                                        "
			.string 0x18, 27, "[11;22H       Press an Alice board button      "
			.string 0x18, 27, "[12;22H         to pick score threshold        "
			.string 0x18, 27, "[13;22H                                        "
			.string 0x18, 27, "[14;22H             SW5 - Play to 7            "
			.string 0x18, 27, "[15;22H                                        "
			.string 0x18, 27, "[16;22H             SW4 - Play to 9            "
			.string 0x18, 27, "[17;22H                                        "
			.string 0x18, 27, "[18;22H             SW3 - Play to 11           "
			.string 0x18, 27, "[19;22H                                        "
			.string 0x18, 27, "[20;22H             SW2 - No limit             "
			.string 0x18, 27, "[21;22H                                        ", 0


end_of_round:		.string 0x18, 27,  "[8;22H                                        "
			.string 0x18, 27,  "[9;22H                                        "
			.string 0x18, 27, "[10;22H               Round over               "
			.string 0x18, 27, "[11;22H                                        "
			.string 0x18, 27, "[12;22H                                        "
			.string 0x18, 27, "[13;22H                                        "
			.string 0x18, 27, "[14;22H              Player   won              "
			.string 0x18, 27, "[15;22H                                        "
			.string 0x18, 27, "[16;22H                                        "
			.string 0x18, 27, "[17;22H                                        "
			.string 0x18, 27, "[18;22H          Press 'c' to continue         "
			.string 0x18, 27, "[19;22H                                        "
			.string 0x18, 27, "[20;22H                                        "
			.string 0x18, 27, "[21;22H                                        ", 0


clear_menu:		.string 0x10, 27,  "[8;22H                                        "
			.string 0x10, 27,  "[9;22H                                        "
			.string 0x10, 27, "[10;22H                                        "
			.string 0x10, 27, "[11;22H                                        "
			.string 0x10, 27, "[12;22H                                        "
			.string 0x10, 27, "[13;22H                                        "
			.string 0x10, 27, "[14;22H                                        "
			.string 0x10, 27, "[15;22H                                        "
			.string 0x10, 27, "[16;22H                                        "
			.string 0x10, 27, "[17;22H                                        "
			.string 0x10, 27, "[18;22H                                        "
			.string 0x10, 27, "[19;22H                                        "
			.string 0x10, 27, "[20;22H                                        "
			.string 0x10, 27, "[21;22H                                        ", 0


	.text

	.global output_ansi_string
	.global display_pause_menu
	.global remove_menu
	.global display_new_game_menu
	.global display_end_of_round

ptr_to_pause_text:			.word pause_text
ptr_to_select_game_length:	.word select_game_length
ptr_to_clear_menu:			.word clear_menu
ptr_to_end_of_round:		.word end_of_round

display_pause_menu:

	PUSH {r0, lr}

	LDR r0, ptr_to_pause_text

	BL output_ansi_string

	POP {r0, lr}

	MOV pc, lr

display_new_game_menu:

	PUSH {r0, lr}

	LDR r0, ptr_to_select_game_length

	BL output_ansi_string

	POP {r0, lr}

	MOV pc, lr

remove_menu:

	PUSH {r0, lr}

	LDR r0, ptr_to_clear_menu

	BL output_ansi_string

	POP {r0, lr}

	MOV pc, lr

display_end_of_round:

	PUSH {r0, lr}

	LDR r0, ptr_to_end_of_round

	BL output_ansi_string

	POP {r0, lr}

	MOV pc, lr
	.end
