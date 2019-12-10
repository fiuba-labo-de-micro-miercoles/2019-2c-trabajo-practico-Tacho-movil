MOVER_VUELTA:
LOOP_VUELTA:
	;leemos los	sensores (condicion de corte, PIND4=PIND5=1)
	IN R16, SENSOR_PIN_VUELTA
	ANDI R16, (1<<SENSOR_IZQ_VUELTA) | (1<<SENSOR_DER_VUELTA) ;nos quedamos bit4 y bit5
	CPI R16, 0 ;si el pinD = 0  -> esta bien en la linea -> avanzar
	BREQ PRENDER_AMBOS_MOTORES_VUELTA
	CPI R16, (1<<SENSOR_IZQ_VUELTA) | (1<<SENSOR_DER_VUELTA)
	BREQ FRENAR_VUELTA ;los sensores devolvieron 1 y 1 -> FRENAR_VUELTA
	;si se llega a esta porcion de codigo pinD4 y 5 no son ni 00 ni 11
	SBIC SENSOR_PIN_VUELTA, SENSOR_DER_VUELTA
	RJMP GIRAR_DERECHA_VUELTA ;si SENSOR_DER_VUELTA = 1 -> gira a la DERECHA
	SBIC SENSOR_PIN_VUELTA, SENSOR_IZQ_VUELTA ;si SENSOR_DER_VUELTA dio 1, SENSOR_IZQ_VUELTA sera 0
	RJMP GIRAR_IZQUIERDA_VUELTA ;		SENSOR_DER_VUELTA=0 -> True entonces girar izuierda
	JMP LOOP_VUELTA

EXIT_MOVER_VUELTA:
	RET

GIRAR_IZQUIERDA_VUELTA:
	RCALL APAGAR_MOTOR_IZQ_VUELTA
	RJMP LOOP_VUELTA

GIRAR_DERECHA_VUELTA:
	RCALL APAGAR_MOTOR_DER_VUELTA
	RJMP LOOP_VUELTA

PRENDER_AMBOS_MOTORES_VUELTA:
	;se crea una rutina que prende ambos motores al mismo tiempo para evitar que el carro gire sobre su eje por el retraso entre ruedas
	CLR R17
	;CBI PORT_MOTOR_VUELTA, MOTOR_IZQ_1_VUELTA
	;CBI PORT_MOTOR_VUELTA, MOTOR_DER_1_VUELTA
	IN R17, SENSOR_PIN_VUELTA
	CBR R17, (1<<MOTOR_IZQ_1_VUELTA) | (1<<MOTOR_DER_1_VUELTA) ;para asegurar un 0 en MOTOR_IZQ_1_VUELTA y MOTOR_DER_1_VUELTA
	ORI R17, (1<<MOTOR_IZQ_0_VUELTA) | (1<<MOTOR_DER_0_VUELTA) ;PRENDO MOTOR IZQ_0 Y MOTOR DER_0
	OUT PORT_MOTOR_VUELTA, R17
	JMP LOOP_VUELTA

FRENAR_VUELTA:
	CLR R20
	IN R20, SENSOR_PIN_VUELTA
	CBR R20, (1<<MOTOR_IZQ_1_VUELTA) | (1<<MOTOR_DER_1_VUELTA) | (1<<MOTOR_IZQ_0_VUELTA) | (1<<MOTOR_DER_0_VUELTA) ;limpia las posiciones que elegi
	OUT PORT_MOTOR_VUELTA, R20
	RJMP EXIT_MOVER_VUELTA

APAGAR_MOTOR_IZQ_VUELTA:
	CBI PORT_MOTOR_VUELTA, MOTOR_IZQ_0_VUELTA
	RET

PRENDER_MOTOR_IZQ_VUELTA:
	SBI PORT_MOTOR_VUELTA, MOTOR_IZQ_0_VUELTA
	RET

APAGAR_MOTOR_DER_VUELTA:
	CBI PORT_MOTOR_VUELTA, MOTOR_DER_0_VUELTA
	RET

PRENDER_MOTOR_DER_VUELTA_VUELTA:
	SBI PORT_MOTOR_VUELTA, MOTOR_DER_0_VUELTA
	RET