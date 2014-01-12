;******************************************************************************************
;******************************************************************************************
;*************Programa de control el Reductor Electronico de Energia Electrica*************
;**********----------------------------------------------------------------------**********
;****************************Diseñado por: Ing. Julian Abramson****************************
;****CDE L1(), va definida por el pinC.0; su salida correspondiente L1(out), por pinC.1****
;****CDE L2(), va definida por el pinC.2; su salida correspondiente L2(out), por pinC.7****
;******Las salidas de control, QR1 por el pinB.5, y QR2 por el pinB.4 respectivamente******
;******Los switches de reset SW_1, por el pinB.2 y SW_2 por el pinB.3 respectivamente******
;********Los pines de salida para el Fan y la bocina son B.7 y B.6 respectivamente*********
;************Programa diseñado para el PICAXE 18M2, el 07 de Diciembre del 2013************


#rem
```````````````````````````````````````````````````
` PicAxe 18M2
` Pinout and Definition of Legs
`
`(DAC / Touch / ADC / Out / In) C.2 leg 1
`(SRQ / Out) Serial Out / C.3 leg 2
`(In) / Serial In / C.4 leg 3
`(In) C.5 leg 4
`=======================================
`(gnd) 0v leg 5
`=======================================
`(SRI / Out / In) B.0 leg 6
`(i2c sda / Touch / ADC / Out / In) B.1 leg 7
`(hserin / Touch / ADC / Out / In) B.2 leg 8
`(pwm / Touch / ADC / Out / In) B.3 leg 9
`---------------------------------------
`(i2c scl / Touch / ADC / Out / In) B.4 leg 10
`(hserout / Touch / ADC / Out / In) B.5 leg 11
`(pwm / Touch / ADC / Out / In) B.6 leg 12
`(Touch / ADC / Out / In) B.7 leg 13
`=======================================
`(vcc) +v leg 14
`=======================================
`(Out / In) C.6 leg 15
`(Out / In) C.7 leg 16
`(Touch / ADC / Out / In) C.0 leg 17
`(Touch / ADC / Out / In) C.1 leg 18
`
` end 18M2 definition
`````````````````````````````````````````````````````
#endrem




#simtask1							; Define la task (0, 1, 2 o 3) a simular
#picaxe 18m2						; setea el tipo de PICAXE a usar	

	
	symbol SW_1 = pinB.2				; Define una entrada tipo switch
	symbol SW_2 = pinB.3				; Define una entrada tipo switch
	symbol Qr1 = B.5					; Define el pin de salida de potencia
	symbol Qr2 = B.4					;		"          "
	symbol LED_1 = B.0 				; Define la salida ‘LED_1’ en el pin B.0
	symbol LED_2 = B.1 				; Define la salida ‘LED_2’ en el pin B.1
	

start0:
	
	;inputtype %0000011101010100			; Hace las entradas B.2,4 y 6; y C.0, 1 y
								; 2 Smith Trigger. Las otras TTL 
	suspend 2						; Suspende la task 2 del programa
	low B.0
	let dirsC = %0000000000				; Configurando el puerto C como entradas
	if pinC.0 = 1 and pinC.2 = 1 then tempo1	; Pines de entrada CDE
	goto start0
	
tempo1:
	
	pause 100						; Pequeña pausa (bouncing)
	resume 2
	high B.0
	let b2 = 0						; Varibe sincroniza salidas 2 y 1
	for w0 = 1 to 300					; Pausa de 30 seg.
		pause 100
		if pinC.0 = 0 or pinC.2 = 0 then start0
	next w0
	goto normal	
	
normal:
	
	setint or %00000000,%00000101			; Setea las interrupciones: C.0 y C.2
	suspend 2
	low B.0						; Salida del led_1 es puesto a cero
	if b7 = 1 then supresion
	high Qr1						; Activa la potencia de salida Linea 1
	pause 100
	if pinC.1 = 0 then tempo2			; Pin de salida de CDE del reductor
	goto normal		

tempo2:

	resume 2
	high B.0
	for b3 = 1 to 30					; Pausa de 3 segundos
		pause 100
		if pinC.1 = 1 then normal
	next b3
	goto supresion	
	
supresion:
	
	pause 100						; pequeña pausa (bouncing)
	low Qr1						; Apaga la potencia de salida Linea 1
	let b2 = 1
	if pinC.0 = 0 then start0
	goto reposo	
	
reposo:

	if SW_1 = 0 and SW_2 = 0 then tempo1
	goto supresion
		
start1:
	
	let b12 = 0						; Variable de proteccion ventilador
	let w5 = 0						; Variable del timer de temperatura
	pullup %0000100000000100			; Enable los resistore internos			; 
								; en los pines indicados, C.3 y B.2
	suspend 3						; Suspende la task 3 del programa
	low B.1
	let dirsB = %11110011				; Configurando el puerto B
	if pinC.2 = 1 and pinC.0 = 1 then tempo3
	goto start1
	
tempo3:
	
	pause 100						; Pequeña pausa (bouncing)
	resume 3
	high B.1
	let b7 = 0						; Variable sincroniza salidas 1 y 2
	for w2 = 1 to 300					; Pausa de 30 seg.
		pause 100
		if pinC.2 = 0 or pinC.0 = 0 then start1
	next w2
	goto normal_1	
	
normal_1:

	let b8 = 1						; Variable para el control de las
								; interrupciones de entrada C.0 y C.2
	suspend 3
	inc w5						; Incrementa la variable b10
	if w5 > 1000 then
	goto temp_0
	end if
	low B.1
	if b2 = 1 then supresion_1
	high Qr2						; Activa la potencia de salida Linea 2
	pause 60
	if pinC.7 = 0 then tempo4
	goto normal_1
			

tempo4:

	resume 3
	high B.1
	for b6 = 1 to 30					; Pausa de 3 segundos
		pause 100
		if pinC.7 = 1 then normal_1
	next b6
	goto supresion_1	
	
supresion_1:

	pause 100						; Pequeña pausa (bouncing)
	low Qr2						; Apaga la potencia de salida Linea 2
	let b7 = 1
	if pinC.2 = 0 then start1
	goto reposo_1	
	
reposo_1:
	
	if SW_2 = 0 and SW_1 = 0 then tempo3
	goto supresion_1
	
start2:

	high LED_1 						; LED_1 on
	pause 150 						; Espera de 0.25 sec.
	low LED_1 						; LED_1 off
	pause 100 						; Espera de 0.25 sec.
	goto start2		 					
	
start3:

	high LED_2 						; LED_1 on
	pause 150 						; Espera de 0.25 sec.
	low LED_2 						; LED_1 off
	pause 100 						; Espera de 0.25 sec.
	goto start3		 			

interrupt:							; La etiqueta intterrupt, y sus
								; declaraciones
	if b8 = 1 then
	wait 2
	high B.0 : high B.1
	elseif pinC.0 = 0 or pinC.2 = 0 then
	let b7 = 1 : let b2 = 1
	high B.0 : high B.1
	low Qr1 : low Qr2
	do : loop while pinC.0 = 0 or pinC.2 = 0
	else
	let b7 = 0 : let b2 = 0
	endif
	pause 100
	low B.0 : low B.1
	inc b8
	setint or %00000000,%00000101
	return
		
temp_0:

	readtemp C.6,b9					; Lee el sensor de temp (DS18B20), y lo
								; almacena en la variable b9
	if b9 < 101 then					; Setea la temperatura inferior del Fan
								; a 30 grados centigrados
	goto temp_2
	elseif b9 > 108 then				; Setea la temperatura superior del Fan
								; a 50 grados centigrados
	goto temp_1
	else
	goto normal_1
	end if		
	
temp_1:

	wait 5        	;PRUEBA
	high B.7						; Pin de salida para el Fan
	let w5 = 0						; Activa la salida del Fan
	inc b12						; Incrementa b12
	if b12 > 3 then
	gosub sonido
	let b12 = 0
	end if
	goto normal_1

temp_2:

	wait 5		;PRUEBA
	low B.7						; Pin de salida para el Fan
	let w5 = 0						; Desactiva la salida del Fan
	goto normal_1
	
sonido:

	sound B.6,(120,30,125,30)			; Emite tonos de sirena				; 
	pause 2000
	low B.6
	return




#rem
Main:						'PWM CORREGIR LOS PINES B.3 y B.6

	for b1= 0 to 255 step 2 	' counter loop so LED has multiple PWM cycles
		pwm 2,b1,1 			' PWM pin 2 LED one cycle increasin pulse width
		pwm 4,b1,1 			' PWM pin 4 LED one cycle increasing pulse width
	next b1 				' effect is a pleasing surging brightne ss increase
	
	for b1= 255 to 0 step -2
		pwm 2,b1,1 			' PWM pin 2 LED one cycle decreasing pulse width
		pwm 4,b1,1 			' PWM pin 4 LED one cycle decreasing pulse width
	next b1

goto main 
#endrem