/*
 * main.asm
 *
 *  Created: 11/26/2019 7:14:19 PM
 *   Author: Viviana
 */ 

	.INCLUDE "m328pdef.inc"
	.DEF AUX=R16
	.DEF R_USART=R20
	.DEF USART_ESCRIBIR=R17

	.CSEG
	.ORG 0x00
		RJMP RESET
;	.ORG URXCaddr 		
;		RJMP ISR_USART_RX_COMPLETE 
	.ORG INT_VECTORS_SIZE

RESET:
	LDI	AUX,LOW(RAMEND);inicializo el puntero al stack
	OUT	SPL,AUX
	LDI	AUX,HIGH(RAMEND)
	OUT	SPH,AUX	

	RCALL USART_INIT
;	SEI


MAIN:

	RCALL ISR_USART_RX_COMPLETE
	MOV USART_ESCRIBIR,R_USART
	RCALL USART_TRANSMIT
;	RCALL DELAY
	RJMP MAIN


USART_INIT:
	LDI AUX, 0x00
	STS	UBRR0H, AUX ;cargo 0 en la parte high de UBRR0 que tiene 4 bits
	LDI AUX, 0x67;cargo 103 en la parte low de UBRR0, vale 103 para que la baud rate sea 9600 como la del bluetooth pag 165
	STS UBRR0L, AUX

	LDI AUX,(1<<RXEN0)|(1<<TXEN0)
	STS UCSR0B,AUX
		
	LDI AUX, (1<<USBS0)|(1<<UCSZ00)	;modo asincronico pag 161
	STS	UCSR0C, AUX

;	LDI AUX, (1<<UCSZ01)|(1<<UCSZ00)	;modo asincronico pag 161
;	STS	UCSR0C, AUX


;	LDI AUX, (1<<RXEN0)	; Habilito las interrupciones pag 160
;	STS	UCSR0B, AUX

	RET

ISR_USART_RX_COMPLETE:
	push r21
LOOP2:
	LDS R21,UCSR0A
	SBRS R21,RXC0
	RJMP LOOP2 

	LDS	R_USART, UDR0			;COPIA EL UDR EN R_USART para después pasarlo a los motores
;	MOV AUX,R_USART
;	CP AUX,REG_BOTON_ADELANTE
;	BREQ ACA 
;	RCALL MOVER_TACHO_RETIRADA
;	RETI
;ACA:
;	RCALL MOVER_TACHO_ADELANTE
;	RETI
	RET
USART_TRANSMIT:
	PUSH R20
LOOP:
	LDS R20,UCSR0A
	SBRS R20,UDRE0
	RJMP LOOP
	STS UDR0,USART_ESCRIBIR
	POP R20
	RET

DELAY:
    ldi  r18, 50
    ldi  r19, 150
    ldi  r20, 128
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
	RET