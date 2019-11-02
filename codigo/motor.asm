/*
 * motor.asm
 *
 *  Created: 30/10/2019 19:10:03
 *   Author: Santi
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

.EQU SENSOR_IZQ = PIND5 ; pinD 4 es el sensor izquierdo
.EQU SENSOR_DER = PIND4 ;pinD 5 es el sensor derecho
.EQU MOTOR_IZQ = PIND1 ;motor izquierdo para mover tacho
.EQU MOTOR_DER = PIND0 ;motor derecho para mover tacho

.CSEG
.ORG 
MOVER_TACHO_ADELANTE:
CONFIG:
	;setear como entrada los pintes de c/u de los sensores (AHORA DDRD)
	CBI DDRD, SENSOR_IZQ 
	CBI DDRD, SENSOR_DER
	;seteo como salida los pines que controlan el motor (AHORA DDRD)
	SBI DDRD, MOTOR_IZQ
	SBI DDRD, MOTOR_DER
	RCALL PRENDER_AMBOS_MOTORES
LOOP:	
	;leemos los sensores (condicion de corte, PIND4=PIND5=1)
	IN R16, PIND
	ANDI R16, 1<<PIND4 || 1<<PIND5 ;nos quedamos bit4 y bit5
	CPI R16, 0 ;si el pinD = 0  -> esta bien en la linea -> avanzar
	BREQ LOOP
	ANDI R16, 1<<PIND4 || 1<<PIND5 ;nos quedamos bit4 y bit5
	CPI R16, 1<<PIND4 || 1<<PIND5
	BREQ EXIT_MOVER_TACHO_ADELANTE ;los sensores devolvieron 1 y 1 -> frenar
	;si se llega a esta porcion de codigo pinD4 y 5 no son ni 00 ni 11
	SBIC PORTD, PIND4
	RJMP GIRAR_IZQUIERDA ;si pind4 = 1 -> gira a la izquierda
	RJMP GIRAR_DERECHA ;		¿es mejor poner RCALL o RJMP? 

EXIT_MOVER_TACHO_ADELANTE:
	RET

GIRAR_IZQUIERDA:
	RCALL APAGAR_MOTOR_IZQ
	RCALL DELAY
	RCALL PRENDER_MOTOR_IZQ
	RET  ;#### o RJMO LOOP si no queremos que sea una rutina (¿¿que es mas conveniente??)

GIRAR_DERECHA:
	RCALL APAGAR_MOTOR_DER
	RCALL DELAY
	RCALL PRENDER_MOTOR_DER
	RET ;#### o RJMO LOOP si no queremos que sea una rutina (¿¿que es mas conveniente??)

PRENDER_AMBOS_MOTORES:
	;se crea una rutina que prende ambos motores al mismo tiempo para evitar que el carro gire por el retraso entre ruedas
	IN R16, PORTD
	ORI R16, 1<<MOTOR_IZQ || 1<< MOTOR_DER
	OUT PORTD, R16
	RET

APAGAR_MOTOR_IZQ:
	CBI PORTD, MOTOR_IZQ
	RET

PRENDER_MOTOR_IZQ:
	SBI PORTD, MOTOR_IZQ
	RET

APAGAR_MOTOR_DER:
	CBI DDRD, MOTOR_DER
	RET

PRENDER_MOTOR_DER:
	SBI DDRD, MOTOR_DER
	RET

DELAY:
	;esta rutina es un delay de T tiempo que servira para ir girando el carro de a poquito
	LDI R16, 100
LOOP_DELAY:
	DEC R16
	BREQ EXIT_DELAY
	RJMP LOOP_DELAY

EXIT_DELAY:
	RET
	 
	
