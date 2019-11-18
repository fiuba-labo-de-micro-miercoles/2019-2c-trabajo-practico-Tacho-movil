/*
 * motor.asm
 *
 *  Created: 30/10/2019 19:10:03
 *  atmega328p
 *	clk: 16 MHz
 */ 

.include "m328pdef.inc"

; esta rutina controla el desplazamiento del tacho
/*
cuando el sensor izquierdo detecta negro -> girar a la izquierda
cuando el sensor derecho detecta negro -> girar a la derecha
se detecta NEGRO cuando hay un UNO LOGICO en cierto pin (a definir)
se detecta BLANCO cuando hay un CERO LOGICO en cierto pin (a definir)

	TABLA DE COMPORTAMIENTO

SENSOR_IZQ | SENSOR_DER  |   MOVIMIENTO
	0	   |     0       |	   avanzar
	0	   |	 1		 |	 girar a der
	1	   |	 0		 |   girar a izq
	1	   |	 1		 |	   frenar
*/
.EQU SENSOR = PIND
.EQU SENSOR_IZQ = PIND5 ;sensor izquierdo
.EQU SENSOR_DER = PIND4 ;sensor derecho
;Dos pines para cada motor para poder cambiar la direccion de giro (ESTOS PINES SE CONECTAN AL PUENTE H)
.EQU MOTOR_IZQ_0 = PIND6 ;motor izquierdo para mover tacho
.EQU MOTOR_IZQ_1 = PIND7 ;motor izquierdo para mover tacho
.EQU MOTOR_DER_0 = PIND0 ;motor derecho para mover tacho
.EQU MOTOR_DER_1 = PIND1 ;motor izquierdo para mover tacho

.CSEG
RJMP MAIN

MAIN:
.ORG INT_VECTORS_SIZE
	CBI PORTC,5
	
	;STACK POINTER
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16

CONFIG:
	;setear como entrada los pintes de c/u de los sensores (AHORA DDRD)
	CBI DDRD, SENSOR_IZQ 
	CBI DDRD, SENSOR_DER
	;seteo como salida los pines que controlan el motor (DOS POR CADA MOTOR)(AHORA USANDO DDRD)
	SBI DDRD, MOTOR_IZQ_0
	SBI DDRD, MOTOR_IZQ_1
	SBI DDRD, MOTOR_DER_0
	SBI DDRD, MOTOR_DER_1
	SBI DDRC,5 ;pin de prueba VERDE
	SBI DDRC,4 ;pin de prueba ROJO
;A:
	;RCALL PRENDER_AMBOS_MOTORES

LOOP:
	SBI PORTC,5
	;RCALL DELAY_500MS
	;RCALL DELAY_500MS
	;CBI PORTC,5
	;RCALL DELAY_500MS
	;RCALL DELAY_500MS
	;leemos los	sensores (condicion de corte, PIND4=PIND5=1)
	IN R16, SENSOR
	ANDI R16, 1<<SENSOR_IZQ | 1<<SENSOR_DER ;nos quedamos bit4 y bit5
	CPI R16, 0 ;si el pinD = 0  -> esta bien en la linea -> avanzar
	BREQ PRENDER_AMBOS_MOTORES
	SBI PORTC,4 ;LED 
	CPI R16, 1<<SENSOR_IZQ | 1<<SENSOR_DER
	BREQ FRENAR ;los sensores devolvieron 1 y 1 -> frenar
	;si se llega a esta porcion de codigo pinD4 y 5 no son ni 00 ni 11
	SBIC PORTD, SENSOR_DER
	RCALL GIRAR_DERECHA ;si SENSOR_DER = 1 -> gira a la DERECHA
	SBIC PORTD, SENSOR_IZQ ;si sensor_der dio 1, sensor_izq sera 0
	RCALL GIRAR_IZQUIERDA ;		SENSOR_DER=0 -> True entonces girar izuierda
	RJMP LOOP	
	;RCALL DELAY_500ms
	

;EXIT_MOVER_TACHO_ADELANTE:
;	RET

GIRAR_IZQUIERDA:
	RCALL APAGAR_MOTOR_IZQ
	;RCALL DELAY_500MS
	;RCALL PRENDER_MOTOR_IZQ
	RET

GIRAR_DERECHA:
	RCALL APAGAR_MOTOR_DER
	;RCALL DELAY_500MS
	;RCALL PRENDER_MOTOR_DER
	RET


PRENDER_AMBOS_MOTORES:
	SBI PORTC,5 ;LED VERDE
	;se crea una rutina que prende ambos motores al mismo tiempo para evitar que el carro gire sobre su eje por el retraso entre ruedas
	IN R17, SENSOR
	ORI R17, 1<<MOTOR_IZQ_0 | 1<<MOTOR_DER_1 ;PRENDO MOTOR IZQ_0 Y MOTOR DER_1
	;ORI R16, 0b01000010 ;1<<MOTOR_IZQ_0 | 1<<MOTOR_DER_1
	;LDI R18, (0xFF -  (1<<MOTOR_IZQ_1 | 1<<MOTOR_DER_0)) ;0's en motor_der_0 y motor_izq_1
	;ANDI R16, 0b01111110
	;AND R17,R18
	OUT PORTD, R17
	RJMP LOOP

FRENAR:
	IN R16, 0xFF
	CBR R16, 1<<MOTOR_IZQ_1 |1<<MOTOR_DER_1 | 1<<MOTOR_IZQ_0 | 1<<MOTOR_DER_0 ;limpia las posiciones que elegi
	OUT PORTD, R16
	CBI PORTC,5
	RCALL DELAY_500ms
	CBI PORTC,4
	RCALL DELAY_500ms
	RJMP LOOP

;REVISAR RUTINAS DE PRENDER/APAGAR MOTORES, HACERLAS DE FORMA MAS GENERICA PARA APAGAR/PRENDER INDEPENDIENTE
;DEL SENTIDO DE GIRO QUE TENGA EL MOTOR EN EL MOMENTO
APAGAR_MOTOR_IZQ:
	CBI PORTD, MOTOR_IZQ_0
	RET

PRENDER_MOTOR_IZQ:
	SBI PORTD, MOTOR_IZQ_0
	RET

APAGAR_MOTOR_DER:
	CBI PORTD, MOTOR_DER_1
	RET

PRENDER_MOTOR_DER:
	SBI PORTD, MOTOR_DER_1
	RET

DELAY_500ms:
    ldi  r18, 41
    ldi  r19, 150
    ldi  r20, 128
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
	RET
