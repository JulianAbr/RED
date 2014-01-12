;******************************************************************************************
;******************************************************************************************
;*************Programa de control el Reductor Electronico de Energia Electrica*************
;**********----------------------------------------------------------------------**********
;****************************Diseñado por: Ing. Julian Abramson****************************
;****CDE L1(), va definida por el pinC.0; su salida correspondiente L1(out), por pinC.1****
;****CDE L2(), va definida por el pinB.5; su salida correspondiente L2(out), por pinB.4****
;******Las salidas de control, QR1 por el pinC.2, y QR2 por el pinB.3 respectivamente******
;*******Los swithes de reset SW_1, por el pinC.3 y SW_2 por el pinB.2 respectivamente******
;************Programa diseñado para el PICAXE 14M2, el 07 de Diciembre del 2013************

;#simtask1							; Define la task (0, 1, 2 o 3) a simular
#picaxe 14m2						; setea el tipo de PICAXE a usar	

	symbol SW_1 = pinC.3				; Define una entrada tipo switch
	symbol SW_2 = pinB.2				; Define una entrada tipo switch
	symbol Qr1 = C.2					; Define el pin de salida de potencia
	symbol Qr2 = B.3					;		"          "
	symbol LED_1 = C.4 				; Define la salida ‘LED_1’ en el pin C.4
	symbol LED_2 = B.1 				; Define la salida ‘LED_2’ en el pin B.1
	
start0:
	
	pause 100						; pequeña pausa (bouncing)
	inputtype %0000101100110100			; Hace las entradas B.2,4 y 5; y C.0,
								; 1 y 3 Smith Trigger. Las otras TTL 
	suspend 2						; Suspende la task 2 del programa
	low C.4
	let dirsC = %000010100				; Configurando el puerto C
	if pinC.0 = 1 and pinB.5 = 1 then tempo1	; Pines de entrada CDE
	goto start0
	
tempo1:

	resume 2
	high C.4
	let b2 = 0						; Varibe sincroniza salidas 2 y 1
	for w0 = 1 to 300					; Pausa de 30 seg.
		pause 100
		if pinC.0 = 0 or pinB.5 = 0 then start0
	next w0
	goto normal	
	
normal:

	suspend 2
	low C.4						; Salida del led_1 es puesto a cero
	if b7 = 1 then supresion
	high Qr1						; Activa la potencia de salida Linea 1
	pause 100
	if pinC.1 = 0 then tempo2			; pin de salida de CDE del reductor
	goto normal		

tempo2:

	resume 2
	high C.4
	for b3 = 1 to 30
		pause 100
		if pinC.1 = 1 then normal
	next b3
	;suspend 2						; Comentar estas lineas, para saber 
	;low C.4						; cual de las dos salidas fallo   
	goto supresion	
	
supresion:
	
	pause 100						; pequeña pausa (bouncing)
	low Qr1						;Apaga la potencia de salida Linea 1
	let b2 = 1
	if pinC.0 = 0 then start0
	goto reposo	
	
reposo:

	if SW_1 = 0 and SW_2 = 0 then tempo1
	goto supresion
		
start1:
	pullup %0000100000000100			; Enable los resistore internos			; 
								; en los pines indicados, C.3 y B.2
	suspend 3						; Suspende la task 3 del programa
	low B.1
	let dirsB = %000001010				; Configurando el puerto B
	if pinB.5 = 1 and pinC.0 = 1 then tempo3
	goto start1
	
tempo3:
	
	pause 100						; pequeña pausa (bouncing)
	resume 3
	high B.1
	let b7 = 0						; Variable sincroniza salidas 1 y 2
	for w2 = 1 to 300					; Pausa de 30 seg.
		pause 100
		if pinB.5 = 0 or pinC.0 = 0 then start1
	next w2
	goto normal_1	
	
normal_1:

	suspend 3
	low B.1
	if b2 = 1 then supresion_1
	high Qr2						;Activa la potencia de salida Linea 2
	pause 100
	if pinB.4 = 0 then tempo4
	goto normal_1		

tempo4:

	resume 3
	high B.1
	for b6 = 1 to 30
		pause 100
		if pinB.4 = 1 then normal_1
	next b6
	;suspend 3						; Comentar estas lineas, para saber
	;low B.1						; cual de las dos salidas fallo
	goto supresion_1	
	
supresion_1:
	
	pause 100						; pequeña pausa (bouncing)
	low Qr2						;Apaga la potencia de salida Linea 2
	let b7 = 1
	if pinB.5 = 0 then start1
	goto reposo_1	
	
reposo_1:
	
	if SW_2 = 0 and SW_1 = 0 then tempo3
	goto supresion_1
	
start2:

	high LED_1 						; LED_1 on
	pause 50 						; Espera de 0.25 sec.
	low LED_1 						; LED_1 off
	pause 50 						; Espera de 0.25 sec.
	goto start2		 					
	
start3:

	high LED_2 						; LED_1 on
	pause 50 						; Espera de 0.25 sec.
	low LED_2 						; LED_1 off
	pause 50 						; Espera de 0.25 sec.
	goto start3
