MOVER:
LOOP:
	;leemos los	sensores (condicion de corte, PIND4=PIND5=1)
	IN R16, SENSOR
	ANDI R16, 1<<SENSOR_IZQ | 1<<SENSOR_DER ;nos quedamos bit4 y bit5
	CPI R16, 0 ;si el pinD = 0  -> esta bien en la linea -> avanzar
	BREQ PRENDER_AMBOS_MOTORES
	CPI R16, 1<<SENSOR_IZQ | 1<<SENSOR_DER
	BREQ FRENAR ;los sensores devolvieron 1 y 1 -> frenar
	;si se llega a esta porcion de codigo pinD4 y 5 no son ni 00 ni 11
	SBIC PORTD, SENSOR_DER
	RJMP GIRAR_DERECHA ;si SENSOR_DER = 1 -> gira a la DERECHA
	SBIC PORTD, SENSOR_IZQ ;si sensor_der dio 1, sensor_izq sera 0
	RCALL GIRAR_IZQUIERDA ;		SENSOR_DER=0 -> True entonces girar izuierda
	JMP LOOP	
	;RCALL DELAY_500ms
	CBI PORTC, 0

EXIT_MOVER:
	RET

GIRAR_IZQUIERDA:
	RCALL APAGAR_MOTOR_IZQ
	;RCALL DELAY_500MS
	;RCALL PRENDER_MOTOR_IZQ
	RJMP LOOP

GIRAR_DERECHA:
	RCALL APAGAR_MOTOR_DER
	;RCALL DELAY_500MS
	;RCALL PRENDER_MOTOR_DER
	RJMP LOOP

PRENDER_AMBOS_MOTORES:
	;se crea una rutina que prende ambos motores al mismo tiempo para evitar que el carro gire sobre su eje por el retraso entre ruedas
	CLR R17
	;CBI PORTD, MOTOR_IZQ_1
	;CBI PORTD, MOTOR_DER_1
	IN R17, SENSOR
	CBR R17, 1<<MOTOR_IZQ_1 | 1<<MOTOR_DER_1 ;para asegurar un 0 en motor_izq_1 y motor_der_1
	ORI R17, 1<<MOTOR_IZQ_0 | 1<<MOTOR_DER_0 ;PRENDO MOTOR IZQ_0 Y MOTOR DER_0
	;ORI R16, 0b01000010 ;1<<MOTOR_IZQ_0 | 1<<MOTOR_DER_1
	;LDI R18, (0xFF -  (1<<MOTOR_IZQ_1 | 1<<MOTOR_DER_0)) ;0's en motor_der_0 y motor_izq_1
	OUT PORTD, R17
	JMP LOOP

FRENAR:
	CLR R16
	IN R16, SENSOR
	CBR R16, 1<<MOTOR_IZQ_1 |1<<MOTOR_DER_1 | 1<<MOTOR_IZQ_0 | 1<<MOTOR_DER_0 ;limpia las posiciones que elegi
	OUT PORTD, R16
	RJMP EXIT_MOVER

;REVISAR RUTINAS DE PRENDER/APAGAR MOTORES, HACERLAS DE FORMA MAS GENERICA PARA APAGAR/PRENDER INDEPENDIENTE
;DEL SENTIDO DE GIRO QUE TENGA EL MOTOR EN EL MOMENTO
APAGAR_MOTOR_IZQ:
	CBI PORTD, MOTOR_IZQ_0
	RET

PRENDER_MOTOR_IZQ:
	SBI PORTD, MOTOR_IZQ_0
	RET

APAGAR_MOTOR_DER:
	CBI PORTD, MOTOR_DER_0
	RET

PRENDER_MOTOR_DER:
	SBI PORTD, MOTOR_DER_0
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