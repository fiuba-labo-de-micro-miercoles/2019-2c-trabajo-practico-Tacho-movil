/*
 * main.asm
 *
 *  Created: 28/11/2019 21:05:18
 *   Author: chiqu
 */ 

 
	.DEF AUX = R16
	.EQU BOTON_ADELANTE = 57 ;9 en ascii
	.EQU BOTON_ATRAS = 53	;5 en ascii
	

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

	;seteando como salida los pines que controlan el motor (DOS POR CADA MOTOR)(AHORA USANDO DDRD)
	SBI DDRD, MOTOR_IZQ_0
	SBI DDRD, MOTOR_IZQ_1
	SBI DDRD, MOTOR_DER_0
	SBI DDRD, MOTOR_DER_1

	;CONFIGURACION DE PINES
	;APAGAR TODOS LOS MOTORES AL INICIO
	CLR AUX
	LDI AUX, (0<<MOTOR_IZQ_1) | (0<<MOTOR_IZQ_0) | (0<<MOTOR_DER_1) | (0<<MOTOR_DER_0)
	OUT PORTD, AUX

	;configuracion de sensores
	;CONFIGURACION DE SENSORES
	;seteo como entrada
	CBI DDRB, SENSOR_IZQ
	CBI DDRB, SENSOR_DER
	CBI DDRD, SENSOR_IZQ
	CBI DDRD, SENSOR_DER
	;seteando PORTBn en 0 PARA DESACTIVAR LA RESISTENCIA PULL-UP
	CBI PORTB, SENSOR_IZQ
	CBI PORTB, SENSOR_DER
	CBI PORTD, SENSOR_IZQ
	CBI PORTD, SENSOR_DER
	SBI PORTD, 0
	;----;

	;habilitio la comunicación e interrupciones
	RCALL USART_INIT 
	SEI

HERE:
	RJMP HERE

;--------------------;
;RUTINA DE INTERRUPCION
ISR_USART:
	LDS R18, UDR0
	CPI R18, BOTON_ADELANTE
	BREQ AVANZAR_TACHO
	CPI R18, BOTON_ATRAS
	;BREQ RETROCEDER_TACHO
	BREQ AVANZAR_TACHO
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
	/*
	tendrá que avanzar si y solo si ambos
	sensores devuelven 0 (ven blanco)
	*/

	.SET PORT_MOTOR = PORTD
	.SET SENSOR_IZQ = PIND5 ;sensor izquierdo
	.SET SENSOR_DER = PIND4 ;sensor derecho
	;Dos pines para cada motor para poder cambiar la direccion de giro (ESTOS PINES SE CONECTAN AL PUENTE H)
	.SET MOTOR_IZQ_0 = PIND6 ;motor izquierdo para mover tacho
	.SET MOTOR_IZQ_1 = PIND7 ;motor izquierdo para mover tacho
	.SET MOTOR_DER_0 = PIND2 ;motor derecho para mover tacho
	.SET MOTOR_DER_1 = PIND3 ;motor izquierdo para mover tacho
	.SET SENSOR_PIN = PIND
	.SET SENSOR_PORT = PORTD

	;---;
	;comparación para saber si ambos sensores ven 0 (blanco) y en dicho caso avanzar
	IN AUX, SENSOR_PIN
	ANDI AUX, (1<<SENSOR_IZQ) | (1<< SENSOR_DER) ;máscara para los pines correspondientes
	CPI AUX, 0
	BREQ MOVERSE
	RJMP ETIQUETA_RETI
	/*
RETROCEDER_TACHO:
	.SET PORT_MOTOR = PORTD
	.SET SENSOR_IZQ = PINB5
	.SET SENSOR_IZQ = PINB4
	.SET MOTOR_DER_0 = PIND7
	.SET MOTOR_DER_1 = PIND6
	.SET MOTOR_IZQ_0 = PIND3
	.SET MOTOR_IZQ_1 = PIND2
	.SET SENSOR_PIN = PINB
	.SET SENSOR_PORT = PORTB

	;---;
	;comparación para saber si ambos sensores ven 0 (blanco) y en dicho caso avanzar
	IN AUX, SENSOR_PIN
	ANDI AUX, (1<<SENSOR_IZQ) | (1<< SENSOR_DER) ;máscara para los pines correspondientes
	CPI AUX, 0
	BREQ MOVERSE
	RJMP ETIQUETA_RETI
	*/

MOVERSE:
	CALL MOVER
	RJMP ETIQUETA_RETI



	.nolist
	.INCLUDE "m328pdef.inc"
	.INCLUDE "motor.asm"
	.list
