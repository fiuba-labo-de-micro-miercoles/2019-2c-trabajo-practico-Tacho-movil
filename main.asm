/*
 * main.asm
 *
 *  Created: 11/28/2019 8:48:22 PM
 *   Author: denise
 *	CLK: 16 MHz
 */ 
	.DEF AUX = R16
	.EQU BOTON_ADELANTE = 57 ;9 en ascii
	.EQU BOTON_ATRAS = 53	;5 en ascii
	.EQU SENSOR = PIND
	.SET SENSOR_IZQ = PIND5 ;sensor izquierdo
	.SET SENSOR_DER = PIND4 ;sensor derecho
;Dos pines para cada motor para poder cambiar la direccion de giro (ESTOS PINES SE CONECTAN AL PUENTE H)
	.SET MOTOR_IZQ_0 = PIND6 ;motor izquierdo para mover tacho
	.SET MOTOR_IZQ_1 = PIND7 ;motor izquierdo para mover tacho
	.SET MOTOR_DER_0 = PIND2 ;motor derecho para mover tacho
	.SET MOTOR_DER_1 = PIND3 ;motor izquierdo para mover tacho


	.CSEG
	.ORG 0x00
	RJMP MAIN

	.ORG URXCaddr
	RJMP ISR_USART

	.ORG INT_VECTORS_SIZE

MAIN:
	;inicializo el stack
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R26, HIGH(RAMEND)
	OUT SPH, R16

	;

	;habilitio la comunicación e interrupciones
	RCALL USART_INIT 
	SEI

HERE:
	RJMP HERE

;rutina de interrupción
ISR_USART:
	LDS R18, UDR0
	CPI R18, BOTON_ADELANTE
	BREQ AVANZAR_TACHO
	CPI R18, BOTON_ATRAS
	BREQ RETROCEDER_TACHO
ETIQUETA_RETI:
	RETI

USART_INIT:
	LDI AUX, 0x00
	STS UBRR0H, AUX
	LDI AUX, 0x67
	STS UBRR0L, AUX
	LDI AUX, (1<<RXEN0) | (1<<TXEN0) | (1<<RXCIE0)
	STS UCSR0B, AUX
	LDI AUX, (1<<USBS0) | (3<<UCSZ00)
	STS UCSR0C, AUX

AVANZAR_TACHO:
	.SET SENSOR_IZQ = PIND5 ;sensor izquierdo
	.SET SENSOR_DER = PIND4 ;sensor derecho
	;Dos pines para cada motor para poder cambiar la direccion de giro (ESTOS PINES SE CONECTAN AL PUENTE H)
	.SET MOTOR_IZQ_0 = PIND6 ;motor izquierdo para mover tacho
	.SET MOTOR_IZQ_1 = PIND7 ;motor izquierdo para mover tacho
	.SET MOTOR_DER_0 = PIND2 ;motor derecho para mover tacho
	.SET MOTOR_DER_1 = PIND3 ;motor izquierdo para mover tacho
	CALL MOVER
	RETI

RETROCEDER_TACHO:
	.SET SENSOR_IZQ = PINB5
	.SET SENSOR_IZQ = PINB4
	.SET MOTOR_DER_0 = PIND7
	.SET MOTOR_DER_1 = PIND6
	.SET MOTOR_IZQ_0 = PIND3
	.SET MOTOR_IZQ_1 = PIND2
	CALL MOVER
	RETI

	.nolist
	.INCLUDE "m328pdef.inc"
	.INCLUDE "motor.asm"
	.list
	