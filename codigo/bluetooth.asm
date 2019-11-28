/*
 * bluetooth.asm
 *
 *  Created: 27/11/2019 19:45:26
 *   Author: chiqu
 */ 


 .include "m328pdef.inc"

 .DEF AUX=R16

 .CSEG 
 .ORG 0X00
RJMP MAIN
.org URXCaddr
RJMP ISR_USART

.ORG INT_VECTORS_SIZE

MAIN:
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16

	RCALL USART_INIT
	SEI

LOOP:
	;RCALL USART_ENVIAR
	;RCALL DELAY
    ;CARGO EL VALOR ENVIADO
	RJMP LOOP

ISR_USART:
	RCALL USART_ENVIAR
	RETI

USART_ENVIAR:
	LDS R18, UCSR0A
	SBRS R18, UDRE0
	RJMP USART_ENVIAR 
	LDI R16, '0' ;lo que quiero enviar
	STS UDR0, R16 ;aca lo envio
	RET

USART_INIT:
	;seteo los baudios
	LDI AUX, 0X00
	STS UBRR0H, AUX
	LDI AUX, 0x67
	STS UBRR0L, AUX
	;habilito emision y transmision
	LDI AUX, (1<<RXEN0)|(1<<TXEN0)
	STS UCSR0B, AUX
	;seteo formato: 8data, 2bit de stop
	LDI AUX, (1<<USBS0)|(3<<UCSZ00)
	STS UCSR0C, AUX


	RET

delay:
    ldi  r18, 3
    ldi  r19, 57
    ldi  r20, 46
    ldi  r21, 130
L1: dec  r21
    brne L1
    dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1