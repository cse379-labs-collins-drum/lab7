.data

.text
	.global uart_init
	.global gpio_btn_and_LED_init
	.global output_character
	.global read_character
	.global read_string
	.global output_string
	.global read_from_push_btns
	.global illuminate_LEDs
	.global illuminate_RGB_LED
	.global read_tiva_push_button
	.global division
	.global multiplication
	.global int2string
	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global simple_read_character	; read_character modified for interrupts
	.global lab6


uart_init:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this
						; routine calls another routine.

		; Your code for your uart_init routine is placed here

	MOV r5, #0x0000		; Initialize r5 to zero (LSB)

						; Provide clock to UART0
	MOV r4, #0xE618		; Copy memory address for clock initialization into register r4 (Most significant bits)
	MOVT r4, #0x400F	; Clock initialization memory address (LSB)
	MOV r5, #1			; Set r5 to 1 for transmission
	STR r5, [r4]		; Store signal (r5) in MMIO data ([r4])

						; Enable clock to PortA
	MOV r4, #0xE608		; Change address for next instruction (to 0x400FE608)
	MOVT r4, #0x400F	;
	STR r5, [r4]		; Store signal (r5) in MMIO data ([r4])

						; Disable UART Control
	MOV r4, #0xC030		; Change memory address to 0x4000C030 (MSB)
	MOVT r4, #0x4000	; (MSB)
	AND	r5, r5, #0		; Set r5 to zero
	STR r5, [r4]		; Store signal (r5) in MMIO data ([r4])

						; Set UART_IBRD_R for 115,200 bauds
	MOV r4, #0xC024		; Move pointer to 0x4000C024
	MOVT r4, #0x4000
	MOV r5, #8			; Set r5 to 8
	STR r5, [r4]		; Store signal (r5) in MMIO data ([r4])

						; Set UART_FBRD_R for 115,200 bauds
	MOV r4, #0xC028		; Move pointer to 0x4000C028
	MOVT r4, #0x4000
	MOV r5, #44			; Set r5 to 44
	STR r5, [r4]		; Store signal (r5) in MMIO data ([r4])

						; Use System Clock
	MOV r4, #0xCFC8		; Move pointer to 0x4000CFC8
	MOVT r4, #0x4000
	AND r5, r5, #0		; Set r5 to zero
	STR r5, [r4]		; Store signal (r5) in MMIO data ([r4])

						; Use 8-bit word length, 1 stop bit, no parity
	MOV r4, #0xC02C		; Move pointer to 0x4000C02C
	MOVT r4, #0x4000
	MOV r5, #0x60		; Set r5 to 0x60
	STR r5, [r4]		; Store signal (r5) in MMIO data ([r4])

						; Enable UART0 Contro
	MOV r4, #0xC030		; Move pointer to 0x4000C030
	MOVT r4, #0x4000
	MOV r5, #0x301		; Set r5 to 0x301
	STR r5, [r4]		; Store signal (r5) in MMIO data ([r4])

						; Mark PA0 and PA1 as digital ports
	MOV r4, #0x451C		; Move pointer to 0x4000451C
	MOVT r4, #0x4000
	LDR r5, [r4]		; Load data from memory address
	ORR r5, r5, #0x03	; OR data with mask (0x03)
	STR r5, [r4]

						; Change PA0, PA1 to Use an Alternate Function
	MOV r4, #0x4420		; Move pointer to 0x40004420
	MOVT r4, #0x4000
	LDR r5, [r4]		; Load data from memory address
	ORR r5, r5, #0x03 	; OR data with mask (0x03)
	STR r5, [r4]		; Store signal (r5) in MMIO data ([r4])

						; Configure PA0, PA1 for UART
	MOV r4, #0x452C		; Move pointer to 0x4000452C
	MOVT r4, #0x4000
	LDR r5, [r4]		; Load data from memory address
	ORR r5, r5, #0x11	; OR data with mask (0x11)
	STR r5, [r4]		; Store signal (r5) in MMIO data ([r4])


	POP {r4-r12,lr}		; Restore registers all registers preserved in the
						; PUSH at the top of this routine from the stack.
	mov pc, lr


gpio_btn_and_LED_init:

	PUSH {r4-r12,lr}	; Spill registers to the stack

	; Enable clock for GPIO Ports B, D, F

	MOV r4, #0xE000
	MOVT r4, #0x400F

	LDRB r5, [r4, #0x608]	; Load the current clock set values

	ORR r5, r5, #0x2A		; Set bits one, three, and five (0010 1010)

	STRB r5, [r4, #0x608]	; Store the new clock enable values

	; Set directions for GPIO Port F - Pins 1-3 Output and Pin 4 Input

	MOV r4, #0x5000
	MOVT r4, #0x4002	; Load port F's address into r4

	LDRB r5, [r4, #0x400]	; Load port F's pin directions into r5

	ORR r5, r5, #0xE
	AND r5, r5, #0xEF	; Set bits 1-3 as 1 (output), bit 4 as 0 (input)

	STRB r5, [r4, #0x400]	; Store the new pin direction values

	; Enable port F pins 1-4

	LDRB r5, [r4, #0x51C]	; Load port F's enabled pins into r5

	ORR r5, r5, #0x1E	; Set bits 1-4 as 1(enabled)

	STRB r5, [r4,#0x51C]	; Store the new pin enable values

	; Enable pullup resistor for port F pin 4

	LDRB r5, [r4, #0x510]	; Load port F's pullup resistor values

	ORR r5, r5, #0x10	; Set bit 4 as 1 (enabled)

	STRB r5, [r4, #0x510]	; Store the new pullup resistor values


	; Set pin directions for Port B pins 0-3 (LEDs)	to 1 (output)

	MOV r4, #0x5000
	MOVT r4, #0x4000        ; Load port B's address into r4

	LDRB r5, [r4, #0x400]   ; Load port B's pin directions into r5

	ORR r5, r5, #0xF	; Set bits 0-3 as 1 (output)

	STRB r5, [r4, #0x400]   ; Store the new pin direction values

        ; Enable port B pins 0-3

	LDRB r5, [r4, #0x51C]	; Load port B's enabled pins into r5

	ORR r5, r5, #0xF	; Set bits 0-3 as 1(enabled)

	STRB r5, [r4,#0x51C]	; Store the new pin enable values

	; Set pin direction for port D pins 0-3 (switches 2-5) to 0 (input)

	MOV r4, #0x7000
	MOVT r4, #0x4000

	LDRB r5, [r4, #0x400]	; Load port B's pin directions into r5

	AND r5, r5, #0xF0	; Set bits 0-3 as 0 (input)

	STRB r5, [r4, #0x400]	; Store the new pin direction values

	; Enable port D pins 0-3

	LDRB r5, [r4, #0x51C]	; Load port B's enabled pins into r5

	ORR r5, r5, #0xF	; Set bits 0-3 as 1(enabled)

	STRB r5, [r4,#0x51C]	; Store the new pin enable values

	; DON'T Enable port D's pullup resistors on pins 0-3

	POP {r4-r12,lr}		; Restore registers from stack
	MOV pc, lr


output_character:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this
						; routine calls another routine.

			; Your code for your output_character routine is placed here

output_char_loop:			; Main loop for outputting characters to PuTTy

	MOV r4, #0xC018			; Load the UART Flag register address (least significant bits)
	MOVT r4, #0x4000		; in register r4 (most significant bits)

	LDRB r5, [r4]			; Load the contents of the flag register
	AND r5, r5, #0x20		; into r5 and mask to isolate TxFF

	CMP r5, #0				; If r5 = 1, try again.
	BNE output_char_loop	; Else, continue to transmit information

	MOV r4, #0xC000			; Store the UART0 Data memory address (least significant bits)
	MOVT r4, #0x4000		; in register r4 (most significant bits)

	STRB r0, [r4]			; Store the byte from r0 in the UART0 Data to transmit

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
						; PUSH at the top of this routine from the stack.
	mov pc, lr


read_character:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this
						; routine calls another routine.

			; Your code for your read_character routine is placed here

read_char_loop:

	MOV r4, #0xC018		; Load the UART Flag register address
	MOVT r4, #0x4000	; into r4

	LDRB r5, [r4]		; Load the contents of the flag register
	AND r5, r5, #0x10	; into r5 and mask to isolate RxFE

	CMP r5, #0			; If RxFE isn't equal to 0, loop
	BNE read_char_loop	; to check again

	MOV r4, #0xC000		; Load the UART Data register address
	MOVT r4, #0x4000	; into r4

	LDRB r0, [r4]		; Read the given character into register 0

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
						; PUSH at the top of this routine from the stack.
	mov pc, lr


read_string:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this
						; routine calls another routine.

			; Your code for your read_string routine is placed here

	MOV r4, r0				; Preserve initial memory address in r4 for returning in r0

read_string_loop:
	BL read_character		; Read the character which the user is inputting

	CMP r0, #0xA			; Is character in r0 a line feed?
	BEQ stop_reading_string	; If so, terminate string
	CMP r0, #0xD			; Is character in r0 a carriage return?
	BEQ stop_reading_string	; If so, terminate string

	BL output_character

	STRB r0, [r4]			; Store the character from r0 into memory at the address pointed to by r4
	ADD r4, r4, #1			; Increment the value of r4 so we can move to the next character in memory

	B read_string_loop

stop_reading_string:

	MOV r0, #0
	MOVT r0, #0

	STRB r0, [r4]

	POP {r4-r12,lr}   		; Restore registers all registers preserved in the
							; PUSH at the top of this routine from the stack.
	mov pc, lr

output_string:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this
						; routine calls another routine.

	MOV r4, r0			; Copy the address given into r4

output_string_loop:

	LDRB r0, [r4]			; Load the first byte of the string into r0

	CMP r0, #0
	BEQ end_output_string	; End if the character is NULL

	BL output_character		; The string hasn't terminated, so print the current character

	ADD r4, r4, #1			; Increment the current address of the string

	B output_string_loop	; Continue the loop



end_output_string:

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
						; PUSH at the top of this routine from the stack.
	mov pc, lr


read_from_push_btns:

	PUSH {r4-r12,lr} ; Spill registers to stack

 	; Your code is placed here
	MOV r4, #0x7000
	MOVT r4, #0x4000	; Move Port D's address into r4

	LDRB r5, [r4,#0x3FC]	; Load Port D's data register into r5

	AND r5, r5, #0xF	; Mask the data register to only preserve
				; info on the button pins

	MOV r0, r5		; Return the button values in r0

	POP {r4-r12,lr} ; Restore registers from stack
	MOV pc, lr



	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


illuminate_LEDs:
	PUSH {r4-r12,lr}	; Spill registers to stack

	MOV r4, #0x5000
	MOVT r4, #0x4000

	AND r0, #0xF			; Mask register r0 with #0xF (0 1111)
    STRB r0, [r4, #0x3FC]	; Store information in proper pins

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


illuminate_RGB_LED:
	PUSH {r4,r5,r6} ; Spill registers to stack


	; Write to the RGB LED pins based on the given color
	; Colors will be represented using a 3 bit number.
	; The 0th bit will be red    (001)
	; The 1st bit will be blue   (010)
	; The 2nd bit will be green  (100)
	; Other colors can be created by bitwise or-ing these values
	; Example : Purple is made with the red and blue LEDs being on,
	;           and the green LED being off, so its value is 101
	;
	; All supported colors:
	;	Off    - 000
	;	Red    - 001
	;	Green  - 100
	;	Blue   - 010
	;	Purple - 011
	;	Yellow - 101
	;	Cyan   - 110
	;	White  - 111
	;

	MOV r4, #0x5000
	MOVT r4, #0x4002		; Copy port F's address into r4

	LDRB r5, [r4, #0x3FC]	; Load Port F's data register into r5

	AND r5, r5, #0xF1	; Clear bits 1, 2, and 3. These correspond
				; to the three color pins

	MOV r6, r0

	LSL r6, #1

	ORR r5, r5, r6		; Copy the color bits into the pin values

	STRB r5, [r4, #0x3FC]	; Write the new pin values into memory


	POP {r4,r5,r6} ; Restore registers from stack
	MOV pc, lr


read_tiva_push_button:	; Read the information from SW1 and place in register r0
	PUSH {r4-r12,lr}	; Spill registers to the stack

		; Your code is placed here

	MOV r4, #0x53FC		; Set r4 to the GPIO Port F Pin 4 Data Register
	MOVT r4, #0x4002		; (Most significant bits)

	MOV r0, #0			; Initialize return value to 0 (False)

						; Read GPIO Value
	LDR r5, [r4]		; Load the contents of the Port F Data Register and place in r5 for comparison
	MOV r6, #16			; Load (0001 0000) into r6 for use below
	AND r5, r5, r6		; Mask contents of r5 with (0001 0000) to isolate pin 4
	CMP r5, r6			; Compare r5 with (0001 0000) to see if pin 4 is active
	BEQ	end_read_button	; If switch is open (pin not active), end subroutine
	MOV r0, #1			; If pin active, return value updated to 1

end_read_button:
	POP {r4-r12,lr}		; Restore registers from stack
	MOV pc, lr


division:
	PUSH {r4-r12,lr}	; Store registers r4 through r12 and lr on the
						; stack. Do NOT modify this line of code.  It
    			      	; ensures that the return address is preserved
 		            	; so that a proper return to the C wrapped can be
			      		; executed.

	; Your code for the division routine goes here.

                        ; Dividend in r0
                        ; Divisor in r1
                        ; Return Quotient in r0

    MOV r4, #15         ; Initialize counter to 15
    MOV r5, #0          ; Initialize Quotient to 0

    LSL r1, #15         ; Logical shift left the divisor 15 places

    MOV r6, r0          ; Initialize remainder to dividend

DIVLOOP:

    SUB r6, r6, r1      ; Set remainder to remainder - divisor

    CMP r6, #0
    BGE DIVIF           ; Branch to skip the next lines if the remainder >= 0
                        ; (this is the condition in the flowchart flipped for code layout)

                        ; YES side of chart
    ADD r6, r6, r1      ; Set remainder to remainder + divisor

    LSL r5, #1          ; Logical shift left quotient

    B DIVAFTERIF

DIVIF:

    LSL r5, #1          ; Logical shift left quotient

    ORR r5, #1          ; Set quotient LSB to 1

DIVAFTERIF:

    LSR r1, #1          ; Logical shift right divisor

    CMP r4, #0
    BLE DIVEND

    SUB r4, r4, #1      ; counter is greater than 0, so we decrecment counter and continue the loop

    B DIVLOOP

DIVEND:

    MOV r0, r5

    MOV r1, r6

	POP {r4-r12,lr}		; Restore registers r4 through r12 and lr from
    					; the stack. Do NOT modify this line of code.
    			      	; It ensures that the return address is preserved
 		            	; so that a proper return to the C wrapped can be
			      		; executed.

	; The following line is used to return from the subroutine
	; and should be the last line in your subroutine.

	MOV pc, lr


multiplication:
	PUSH {r4-r12,lr}	; Store registers r4 through r12 and lr on the
						; stack. Do NOT modify this line of code.  It
    			     	; ensures that the return address is preserved
 		            	; so that a proper return to the C wrapped can be
			      		; executed.

	; Your code for the multiplication routine goes here.

    MOV r4, #0           ; Initialize product to 0
    MOV r5, #0           ; Initialize counter to 0

MULLOOP:

	AND r6, r0, #1      ; Mask the first operand to get the LSB

    CMP r6, #1
    BNE MULIF           ; Branch if the LSB of r0 is not 1

    ADD r4, r4, r1      ; We didn't branch, so the LSB
                        ; of r0 is one, and we must add
                        ; r1 to the product

MULIF:                  ; Executes in all cases

    ADD r5, r5, #1      ; Increment counter
    LSL r1, #1          ; Logical shift left r1. This
                        ; multiplies r1 by 2, which is
                        ; needed because we will be
                        ; multiplying by the next
                        ; highest "place" next

    LSR r0, #1          ; Logical shift right r0. This
                        ; is used to "discard" the LSB
                        ; that we already used, so we
                        ; can make a decision on the
                        ; next bit

    CMP r5, #15
    BLT MULLOOP         ; Loop again if the counter is
                        ; less than 15, this would mean
                        ; we have more bits to multiply
                        ; still

    MOV r0, r4          ; We finished the loop, so we
                        ; should move the product into
                        ; the expected return register


	POP {r4-r12,lr}		; Restore registers r4 through r12 and lr from
    					; the stack. Do NOT modify this line of code.
    			      	; It ensures that the return address is preserved
 		            	; so that a proper return to the C wrapped can be
				      	; executed.

	; The following line is used to return from the subroutine
	; and should be the last line in your subroutine.

	MOV pc, lr


int2string:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
				; that are used in your routine.  Include lr if this
				; routine calls another routine.

	MOV r4, #9999
	CMP r1, r4
	BLE LT_9999		;Is r1 <= 9,999?

	MOV r5, #10000		;32,767 >= r1 >= 10,000, so set r5
	B int2string_start	;to 10,000 to isolate the left-most
				;digit

LT_9999:
	MOV r4, #999
	CMP r1, r4		;r1 is <= 9,999
	BLE LT_999		;Is r1 <= 999?

	MOV r5, #1000		;9,999 >= r1 >= 1,000, so set r5
	B int2string_start	;to 1,000 to isolate the left-most
				;digit

LT_999:
	CMP r1, #99		;r1 is <= 999
	BLE LT_99		;Is r1 <= 99?

	MOV r5, #100		;999 >= r1 >= 100, so set r5
	B int2string_start	;to 100 to isolate the left-most
				;digit

LT_99:
	CMP r1, #9		;r1 is <= 99
	BLE LT_9		;Is r1 <= 9?

	MOV r5, #10		;99 >= r1 >= 10, so set r5
	B int2string_start	;to 10 to isolate the left-most
				;digit

LT_9:
	MOV r5, #1		;9 >= r1 >= 0, so set r5
				;to 1 to isolate the left-most
				;digit

int2string_start:
	MOV r8, r0
	MOV r9, r1		;Move r0 and r1 to preserve their values

	MOV r0, r1
	MOV r1, r5
	BL division		;Divide r1 by r5, store in r6
	MOV r6, r0

	MOV r1, r5
	BL multiplication
	MOV r7, r0

	MOV r1, r9
	SUB r1, r1, r7		;Subtract r7 from r1

	ADD r6, r6, #0x30	;Add 0x30 to r6

	MOV r0, r8

	STRB r6, [r0]		;Store the character at r6 into memory at r0

	ADD r0, r0, #1		;Increment r0 by one byte

	CMP r5, #1000
	BNE DIV_R5		;Is r5 == 1,000?

	MOV r6, #0x2C		;Yes, r5 == 1,000
	STRB r6, [r0]		;Store a comma in memory

	ADD r0, r0, #1		;Increment r0 by one byte

DIV_R5:
	MOV r8, r0
	MOV r9, r1
	MOV r0, r5
	MOV r1, #10		;Prepare the registers to call division

	BL division
	MOV r5, r0
	MOV r0, r8
	MOV r1, r9		;Set the register back to how they were
				;before the call to division


	CMP r5, #0
	BNE int2string_start	;Is r5 == 0?

	MOV r6, #0
	STRB r6, [r0]		;Yes, they are equal. Store the
				;NULL character


	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
				; PUSH at the top of this routine from the stack.
	mov pc, lr

uart_interrupt_init:

	PUSH {r4-r12,lr}		; Save registers to stack

							; Set the RXIM bit in the UARTIM to enable interrupt
	MOV r4, #0xC000			; Store UART0 base address in r4 (LSB)
	MOVT r4, #0x4000		; (MSB)
	LDR	r5, [r4, #0x038]	; Load data from UARTIM into register r5
	ORR r5, r5, #0x10		; Set the RXIM bit (Bit 4) to 1 to enable interrupt
	STR r5, [r4, #0x038]	; Store enabled bit in UARTIM

							; Set the 5 bit in the EN0 register
	MOV r4, #0xE000			; Store EN0 base address in r4 (LSB)
	MOVT r4, #0xE000		; (MSB)
	LDR r5, [r4, #0x100]	; Load data from EN0 into r5
	ORR r5, r5, #0x20		; Set the 5 bit to 1
	STR r5, [r4, #0x100]	; Store enabled bit in EN0

	POP {r4-r12,lr}			; Restore registers from stack
	MOV pc, lr


gpio_interrupt_init:

	; Your code to initialize the SW1 interrupt goes here
	; Don't forget to follow the procedure you followed in Lab #4
	; to initialize SW1.

	PUSH {r4, r5}

	MOV r4, #0x5000
	MOVT r4, #0x4002	; Move the Ggpio interrupt address into r4


	; Set edge sensitivity

	LDRB r5, [r4, #0x404]	; Load the current GPIOIS into r5

	AND r5, r5, #0xEF		; Mask the current value with (1110 111)
							; to clear bit 4

	STRB r5, [r4, #0x404]	; Store the new GPIOIS values in memory


	; Set single edge triggering

	LDRB r5, [r4, #0x408]	; Load the current GPIOIBE into r5

	AND r5, r5, #0xEF		; Mask the current value with (1110 111)
							; to clear bit 4

	STRB r5, [r4, #0x408]	; Store the new GPIOIBE values in memory


	; Enable only rising edge interrupt triggering

	LDRB r5, [r4, #0x40C]	; Load the current GPIOIV into r5

	AND r5, r5, #0xEF		; Clear bit 4 to make it falling edge triggering

	STRB r5, [r4, #0x40C]	; Store the new GPIOIV values in memory


	; Enable the GPIO interrupt for the tiva SW1

	LDRB r5, [r4, #0x410]	; Load the current GPIOIM into r5

	ORR r5, r5, #0x10		; Set bit 4 to make it rising edge triggering

	STRB r5, [r4, #0x410]	; Store the new GPIOIM values in memory


	; Configure processor to allow Port F interrupts

	MOV r4, #0xE000
	MOVT r4, #0xE000		; Load the base address of the EN0 into r4

	LDR r5, [r4, #0x100]	; Load the current EN0 into r5

	ORR r5, r5, #0x40000000	; Set bit 30 to allow Port F interrupts


	STR r5, [r4, #0x100]	; Store the new EN0 values in memory

	POP {r4, r5}

	MOV pc, lr


Switch_Handler:

	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r12 by pushing then popping
	; them to & from the stack at the beginning & end of the handler

	PUSH {r4-r12,lr}			; Save registers to stack

								; Clear interrupt
	MOV r4, #0x541C				; Put GPIOCR offset with Port F Base Address in r4 (LSB)
	MOVT r4, #0x04002			; Put GPIO Port F Base Address in r4 (MSB)
	LDRB r5, [r4] 				; Load data from UARTCIR in r5
	MOV r6, #0x10				; Prepare r6 for masking (LSB)
	ORR r5, r5, r6				; Set 4th bit (RXIC) in r5 (XXX1 XXXX)
	STRB r5, [r4]				; Store value from r5 in UARTCIR



exit_GPIO_Handler:
	POP {r4-r12,lr}				; Restore registers from stack
	BX lr 						; Return


simple_read_character:

	PUSH {r4}

	MOV r4, #0xC000		; Load the UART Data register address
	MOVT r4, #0x4000	; into r4

	LDRB r0, [r4]		; Read the given character into register 0

	POP {r4}

	MOV pc, lr	; Return

wait:

	PUSH {r4}

	MOV r4, #0x0900
	MOVT r4, #0x3D

loopfortime:

	SUB r4, r4, #1

	CMP r4, #0
	BNE loopfortime

	POP {r4}

	MOV pc, lr


.end
