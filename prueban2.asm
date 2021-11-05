#INCLUDE <P16F628A.inc>
;***********************************************
;***********************************************
;Fecha: 23/11/2018
;
;Funcion del programa:
;					                           
;Permite ingresar dos numeros positivos,       
;restarlos, generar el resultado y guardarlos.       
;
;
;INTEGRANTES: AGUIAR, ANDRES
;			  BLOISI, MATIAS
;			  CORSICO, CLAUDIO
;			  BLANGILLE, ALAN
;			  CADIMA, ALEX			
;
;
;MATERIA: ARQUITECTURA DE COMPUTADORAS
;
;
;PROFESORES: GARCIA,ROBERTO		
;			 BIANCO, SANTIAGO				
;	    
;***********************************************

__CONFIG 3F10 && _WDT_OFF && _LVP_OFF

		CBLOCK 0x20
		CONT1
		CONT2
		DIG_DSP1
		DIG_DSP2
		DIG_DSP3
		DIG_DSP4
		D1
		D2
		D3
		D4
		AUX_W
		AUX_STATUS
		AUX
		FLAG_M
		FLAG_SIG
		N1_UNIDAD
		N1_DECENA
		N1_CENTENA
		N2_UNIDAD
		N2_DECENA
		N2_CENTENA
		ENDC

;DECLARACION DE CONSTATNES

#DEFINE BTN_G1 	PORTA,6
#DEFINE BTN_G2 	PORTA,7
#DEFINE BTN_R 	PORTA,4
#DEFINE BTN_M 	PORTB,0

#DEFINE PIN_D1 	1
#DEFINE PIN_D2 	0
#DEFINE PIN_D3 	2
#DEFINE PIN_D4 	3

;DECLARACION DE MACROS

MOSTRAR	MACRO	DIGITO,PIN
		CLRF	PORTA
		MOVF	DIGITO,W
		CALL	TAB_DISPLAY
		MOVWF	PORTB
		BSF		PORTA,PIN
		ENDM

LEER_EEPROM	MACRO DIR

		BCF		STATUS,RP0
		MOVLW	DIR
		BSF		STATUS,RP0
		BCF		INTCON,GIE
		MOVWF	EEADR
		BSF		EECON1,RD
		BTFSC	EECON1,RD
		GOTO	$-1
		BCF		EECON1,EEIF
		MOVF	EEDATA,W
		BCF		STATUS,RP0
		BSF		INTCON,GIE

		ENDM

ESCRIBIR_EEPROM MACRO DATO,DIR

		BCF		STATUS,RP0
		MOVLW	DIR
		BSF		STATUS,RP0
		MOVWF	EEADR
		BCF		STATUS,RP0
		MOVF 	DATO,W
		BSF		STATUS,RP0
		MOVWF 	EEDATA
		BSF		EECON1,WREN
		BCF		INTCON,GIE
		MOVLW	0x55
		MOVWF	EECON2
		MOVLW	0xAA
		MOVWF	EECON2
		BSF 	EECON1,WR
		BTFSC 	EECON1,WR
		GOTO 	$-1
		BCF 	EECON1,WREN
		BSF		INTCON,GIE
		BCF 	STATUS,RP0

		ENDM

;INICIO DEL PROGRAMA

		ORG 0x00
		GOTO CONFI
	
		ORG	0X04
;RUTINA DE INTERRUPCION
;GUARDA STATUS Y W EN VARIABLES AUXILIARES
		BCF		INTCON,T0IF
		BCF		INTCON,GIE		
		MOVWF	AUX_W
		MOVLW	STATUS
		MOVWF	AUX_STATUS

;MULTIPLEXADO DE DISPLAYS
		BTFSC	PORTA,PIN_D1
		GOTO	MOSTRAR_D2			
		BTFSC	PORTA,PIN_D2
		GOTO	MOSTRAR_D3
		BTFSC	PORTA,PIN_D3
		GOTO	MOSTRAR_D4

MOSTRAR_D1		
		MOSTRAR	DIG_DSP1,PIN_D1
		GOTO 	FIN_T0I

MOSTRAR_D2
		MOSTRAR DIG_DSP2,PIN_D2
		GOTO 	FIN_T0I

MOSTRAR_D3
		MOSTRAR DIG_DSP3,PIN_D3
		GOTO 	FIN_T0I

MOSTRAR_D4
		MOSTRAR	DIG_DSP4,PIN_D4
		
FIN_T0I
;REINICIA TIMER Y RECUPERA STATUS Y W
		MOVLW	.198
		MOVWF	TMR0
		MOVF	AUX_STATUS,W
		MOVWF	STATUS
		MOVF	AUX_W,W
		RETFIE

;CONFIGURACION
		
CONFI
		MOVLW	0X07
		MOVWF	CMCON ; CMCON SE TIENE QUE ESTABLECER EN 7 PARA USAR TODO EL PORTA
		MOVLW	.198
		MOVWF	TMR0
		BSF		STATUS,RP0
		MOVLW	b'00000001'
		MOVWF	TRISB	
		MOVLW	b'11110000'
		MOVWF	TRISA
		BCF		OPTION_REG,T0CS
		BCF		OPTION_REG,PSA
		BSF		OPTION_REG,PS0
		BSF		OPTION_REG,PS1
		BSF		OPTION_REG,PS2
		BSF		INTCON,GIE
		BSF		INTCON,T0IE
		BCF		STATUS,RP0
		CLRF	FLAG_M
		BCF		FLAG_SIG,0
		;FLAG_M=0 (n1) F = 1 (N2) F = 2 (RESULTADO)
		
;RUTINA PRINCIPAL

		CLRF	PORTA
		CLRF	PORTB
		CALL	LECTURA_GRAL
		
				
BOTONES
		
		BTFSC	BTN_G1
		CALL	BOTON_G1

		BTFSC	BTN_G2
		CALL 	BOTON_G2

		BTFSC	BTN_M
		CALL	BOTON_M

		BTFSC	BTN_R
		CALL 	BOTON_R

		GOTO	BOTONES

TAB_DISPLAY
	ADDWF	PCL,1
	;         GFEDCBA-
	RETLW	b'01111111'	;0
	RETLW	b'00001101' ;1
	RETLW	b'10110111' ;2
	RETLW	b'10011111' ;3
	RETLW	b'11001101' ;4
	RETLW	b'11011011' ;5
	RETLW	b'11111011' ;6
	RETLW	b'00001111' ;7
	RETLW	b'11111111' ;8
	RETLW	b'11001111' ;9
	RETLW	b'10000001'	;-
	RETLW	b'00000001' ;OFF

LECTURA_GRAL

		LEER_EEPROM 0X07
		MOVWF	FLAG_M
		MOVLW	.3
		SUBWF	FLAG_M,W
		BTFSC	STATUS,C
		CLRF	FLAG_M
		
		MOVF	FLAG_M,W
		XORLW	.0
		BTFSC	STATUS,Z
		GOTO	LEER_N1
		MOVF	FLAG_M,W
		XORLW	.1
		BTFSC	STATUS,Z
		GOTO	LEER_N2
		MOVF	FLAG_M,W
		XORLW	.2
		BTFSC	STATUS,Z
		GOTO	LEER_RES
		
LEER_N1
		LEER_EEPROM	0X00
		MOVWF	DIG_DSP1
		MOVLW	.12
		SUBWF	DIG_DSP1,W
		BTFSC	STATUS,C
		CLRF	DIG_DSP1
		LEER_EEPROM	0X01
		MOVWF	DIG_DSP2
		MOVLW	.12
		SUBWF	DIG_DSP2,W
		BTFSC	STATUS,C
		CLRF	DIG_DSP2
		LEER_EEPROM	0X02
		MOVWF	DIG_DSP3
		MOVLW	.12
		SUBWF	DIG_DSP3,W
		BTFSC	STATUS,C
		CLRF	DIG_DSP3
		LEER_EEPROM	0X03
		MOVWF	DIG_DSP4
		MOVLW	.12
		SUBWF	DIG_DSP4,W
		BTFSC	STATUS,C
		CLRF	DIG_DSP4
		GOTO	FIN_LECTURA
;**********************************
LEER_N2
		LEER_EEPROM	0X08
		MOVWF	DIG_DSP1
		MOVLW	.12
		SUBWF	DIG_DSP1,W
		BTFSC	STATUS,C
		CLRF	DIG_DSP1
		LEER_EEPROM	0X09
		MOVWF	DIG_DSP2
		MOVLW	.12
		SUBWF	DIG_DSP2,W
		BTFSC	STATUS,C
		CLRF	DIG_DSP2
		LEER_EEPROM	0X0A
		MOVWF	DIG_DSP3
		MOVLW	.12
		SUBWF	DIG_DSP1,W
		BTFSC	STATUS,C
		CLRF	DIG_DSP3
		LEER_EEPROM	0X0B
		MOVWF	DIG_DSP4
		MOVLW	.12
		SUBWF	DIG_DSP4,W
		BTFSC	STATUS,C
		CLRF	DIG_DSP4
		GOTO	FIN_LECTURA
;***********************************
LEER_RES
		LEER_EEPROM	0X10
		MOVWF	DIG_DSP1
		MOVLW	.12
		SUBWF	DIG_DSP1,W
		BTFSC	STATUS,C
		CLRF	DIG_DSP1
		LEER_EEPROM	0X11
		MOVWF	DIG_DSP2
		MOVLW	.12
		SUBWF	DIG_DSP2,W
		BTFSC	STATUS,C
		CLRF	DIG_DSP2
		LEER_EEPROM	0X12
		MOVWF	DIG_DSP3
		MOVLW	.12
		SUBWF	DIG_DSP3,W
		BTFSC	STATUS,C
		CLRF	DIG_DSP3
		LEER_EEPROM	0X13
		MOVWF	DIG_DSP4
		MOVLW	.12
		SUBWF	DIG_DSP4,W
		BTFSC	STATUS,C
		CLRF	DIG_DSP4

FIN_LECTURA		

		RETURN

TEST_SIG
	
		BTFSS	FLAG_SIG,0
		GOTO	OFF_POS
		GOTO	OFF_NEG

OFF_POS
TEST_DSP3
		MOVF	DIG_DSP3,W
		XORLW	.0
		BTFSS	STATUS,Z
		GOTO	OFF_DSP4
TEST_DSP2
		MOVF	DIG_DSP2,W
		XORLW	.0
		BTFSS	STATUS,Z
		GOTO	OFF_DSP34
TEST_DSP1
		MOVF	DIG_DSP1,W
		XORLW	.0
		BTFSS	STATUS,Z
		GOTO	OFF_DSP234

OFF_DSP4
		MOVLW	.11
		MOVWF	DIG_DSP4
		GOTO	EXIT_TEST

OFF_DSP34
		MOVLW	.11
		MOVWF	DIG_DSP3
		MOVWF	DIG_DSP4
		GOTO	EXIT_TEST

OFF_DSP234
		MOVLW	.11
		MOVWF	DIG_DSP2
		MOVWF	DIG_DSP3
		MOVWF	DIG_DSP4
		GOTO	EXIT_TEST

OFF_NEG
PRUEBO_DSP3
		MOVF	DIG_DSP3,W
		XORLW	.0
		BTFSS	STATUS,Z
		GOTO	SIG_DSP4
PRUEBO_DSP2
		MOVF	DIG_DSP2,W
		XORLW	.0
		BTFSS	STATUS,Z
		GOTO	SIG_DSP3
PRUEBO_DSP1
		MOVF	DIG_DSP1,W
		XORLW	.0
		BTFSS	STATUS,Z
		GOTO	SIG_DSP2

SIG_DSP4
		MOVLW	.10
		MOVWF	DIG_DSP4
		GOTO	EXIT_TEST

SIG_DSP3
		MOVLW	.10
		MOVWF	DIG_DSP3
		MOVLW	.11
		MOVWF	DIG_DSP4
		GOTO	EXIT_TEST

SIG_DSP2
		MOVLW	.10
		MOVWF	DIG_DSP2
		MOVLW	.11
		MOVWF	DIG_DSP4
		MOVWF	DIG_DSP3
		GOTO	EXIT_TEST

EXIT_TEST
		CALL	GUARDAR_RES
		RETURN
		
	

BOTON_G1
		CALL 	DELAY_20MS
		BTFSC	BTN_G1
		RETURN
		CALL	INCREMENTAR
		MOVF	FLAG_M,W
		XORLW	.0
		BTFSC	STATUS,Z
		CALL	GUARDAR_N1
		XORLW	.1
		BTFSC	STATUS,Z
		CALL	GUARDAR_N2
		CALL	GUARDAR_FLAG
		;CALL	TEST_SIG

		RETURN

BOTON_G2
		CALL 	DELAY_20MS
		BTFSC	BTN_G2
		RETURN
		CALL	DECREMENTAR
		MOVF	FLAG_M,W
		XORLW	.0
		BTFSC	STATUS,Z
		CALL	GUARDAR_N1
		XORLW	.1
		BTFSC	STATUS,Z
		CALL	GUARDAR_N2
		CALL	GUARDAR_FLAG
		;CALL	TEST_SIG

		RETURN

BOTON_M
		CALL 	DELAY_20MS
		BTFSC	BTN_M
		RETURN

		MOVF	FLAG_M,W
		XORLW	.0
		BTFSC	STATUS,Z
		GOTO	BOTON_M1
		GOTO	BOTON_M2

FIN_M
		RETURN

BOTON_M1
		INCF	FLAG_M
		CALL	GUARDAR_FLAG
		MOVF	DIG_DSP1,W
		MOVWF	N1_UNIDAD
		MOVF	DIG_DSP2,W
		MOVWF	N1_DECENA
		MOVF	DIG_DSP3,W
		MOVWF	N1_CENTENA
		CALL	GUARDAR_N1
		CLRF	DIG_DSP1
		CLRF	DIG_DSP2
		CLRF	DIG_DSP3
		CLRF	DIG_DSP4
		GOTO	FIN_M

BOTON_M2
		INCF	FLAG_M
		CALL	GUARDAR_FLAG
		MOVF	DIG_DSP1,W
		MOVWF	N2_UNIDAD
		MOVF	DIG_DSP2,W
		MOVWF	N2_DECENA
		MOVF	DIG_DSP3,W
		MOVWF	N2_CENTENA
		CALL	GUARDAR_N2
		CALL	LEO_N1EEPROM
		
		GOTO	VERIFICAR

VERIFICAR
		MOVF	N2_CENTENA,W
		SUBWF	N1_CENTENA,W
		BTFSS	STATUS,C
		CALL	INVERTIR
		BTFSS	STATUS,Z
		GOTO	RESTA
		MOVF	N2_DECENA,W
		SUBWF	N1_DECENA,W
		BTFSS	STATUS,C
		CALL	INVERTIR
		BTFSS	STATUS,Z
		GOTO	RESTA
		MOVF	N2_UNIDAD,W
		SUBWF	N1_UNIDAD,W
		BTFSS	STATUS,C
		CALL	INVERTIR
		GOTO	RESTA

INVERTIR

		MOVF	N1_CENTENA,W
		MOVWF	AUX
		MOVF	N2_CENTENA,W
		MOVWF	N1_CENTENA
		MOVF	AUX,W
		MOVWF	N2_CENTENA


		MOVF	N1_DECENA,W
		MOVWF	AUX
		MOVF	N2_DECENA,W
		MOVWF	N1_DECENA
		MOVF	AUX,W
		MOVWF	N2_DECENA
	
		MOVF	N1_UNIDAD,W
		MOVWF	AUX
		MOVF	N2_UNIDAD,W
		MOVWF	N1_UNIDAD
		MOVF	AUX,W
		MOVWF	N2_UNIDAD

		BSF		FLAG_SIG,0
		MOVLW	.10
		MOVWF	DIG_DSP4

		RETURN

OP_CARRY_UNIDAD
	
	;CHEQUEA UNIDAD
		BSF		STATUS,C
		DECF	N1_DECENA,W;SE LE PIDE 1 A LA DECENA
		BTFSC	STATUS,C
		GOTO SEGUIR

		BSF		STATUS,C
	;SI LA DECENA NO TIENE, SE LE PIDE 1 A LA CENTENA PA LA DECENA
		DECF	N1_CENTENA,F
		MOVF	N1_DECENA,W
		ADDLW	.10
		MOVWF	N1_DECENA

	SEGUIR
		DECF	N1_DECENA,F
	;SI LE PUDIMOS PEDIR 1 A LA DECENA, SE SUMA 10 A LA UNIDAD
		MOVF	N1_UNIDAD,W
		ADDLW	.10
		MOVWF	N1_UNIDAD

		MOVF	N2_UNIDAD,W
		SUBWF	N1_UNIDAD,W

		RETURN
	
OP_CARRY_DECENA
	
	;CHEQUEA CENTENA
		BSF		STATUS,C
		DECF	N1_CENTENA,F;SE LE PIDE 1 A LA CENTENA
	
	;SI LE PUDIMOS PEDIR 1 A LA CEN, SE SUMA 10 A LA DECENA
		MOVF	N1_DECENA,W
		ADDLW	.10
		MOVWF	N1_DECENA

		MOVF	N2_DECENA,W
		SUBWF	N1_DECENA,W
	
		RETURN

RESTA
		MOVF	N2_UNIDAD,W
		SUBWF	N1_UNIDAD,W
		BTFSS	STATUS,C
		CALL	OP_CARRY_UNIDAD
		MOVWF	N1_UNIDAD
		MOVWF	DIG_DSP1

		MOVF	N2_DECENA,W
		SUBWF	N1_DECENA,W
		BTFSS	STATUS,C
		CALL	OP_CARRY_DECENA
		MOVWF	N1_DECENA
		MOVWF	DIG_DSP2

		MOVF	N2_CENTENA,W
		SUBWF	N1_CENTENA,W
		MOVWF	N1_CENTENA
		MOVWF	DIG_DSP3

		CALL	TEST_SIG
		CALL	GUARDAR_RES

		GOTO	FIN_M

BOTON_R
		CLRF	DIG_DSP1
		CLRF	DIG_DSP2
		CLRF	DIG_DSP3
		CLRF	DIG_DSP4
		CLRF	FLAG_M
		CALL	GUARDAR_FLAG
		CALL	GUARDAR_N1
		CALL	GUARDAR_N2
		CALL	GUARDAR_RES
		BCF		FLAG_SIG,0

		RETURN

GUARDAR_N1
		ESCRIBIR_EEPROM	DIG_DSP1,0X00
		ESCRIBIR_EEPROM	DIG_DSP2,0X01
		ESCRIBIR_EEPROM	DIG_DSP3,0X02
		ESCRIBIR_EEPROM	DIG_DSP4,0X03
		
		RETURN

GUARDAR_N2
		ESCRIBIR_EEPROM	DIG_DSP1,0X08
		ESCRIBIR_EEPROM	DIG_DSP2,0X09
		ESCRIBIR_EEPROM	DIG_DSP3,0X0A
		ESCRIBIR_EEPROM	DIG_DSP4,0X0B
		
		RETURN

GUARDAR_RES
		ESCRIBIR_EEPROM	DIG_DSP1,0X10
		ESCRIBIR_EEPROM	DIG_DSP2,0X11
		ESCRIBIR_EEPROM	DIG_DSP3,0X12
		ESCRIBIR_EEPROM	DIG_DSP4,0X13
		
		RETURN

GUARDAR_FLAG
		ESCRIBIR_EEPROM FLAG_M,0X07

		RETURN

LEO_N1EEPROM
		LEER_EEPROM	0X00
		MOVWF	N1_UNIDAD
		LEER_EEPROM 0X01
		MOVWF	N1_DECENA
		LEER_EEPROM 0X02
		MOVWF	N1_CENTENA

		RETURN

INCREMENTAR
	INCF	DIG_DSP1,F
	MOVF	DIG_DSP1,W
	XORLW	.10
	BTFSS	STATUS,Z
	GOTO	FIN_RUT
	CLRF	DIG_DSP1
	INCF	DIG_DSP2,F
	MOVF	DIG_DSP2,W
	XORLW	.10
	BTFSS	STATUS,Z
	GOTO	FIN_RUT
	CLRF	DIG_DSP2
	INCF	DIG_DSP3,F
	MOVF	DIG_DSP3,W
	XORLW	.10
	BTFSS	STATUS,Z
	GOTO	FIN_RUT
	CLRF	DIG_DSP3
FIN_RUT	
	RETURN

DECREMENTAR
	DECF	DIG_DSP1,F
	MOVF	DIG_DSP1,W
	XORLW	0xff
	BTFSS	STATUS,Z
	GOTO	END_RUT
	MOVLW	.9
	MOVWF	DIG_DSP1
	DECF	DIG_DSP2,F
	MOVF	DIG_DSP2,W
	XORLW	0xff
	BTFSS	STATUS,Z
	GOTO	END_RUT
	MOVLW	.9
	MOVWF	DIG_DSP2
	DECF	DIG_DSP3,F
	MOVF	DIG_DSP3,W
	XORLW	0xff
	BTFSS	STATUS,Z
	GOTO	END_RUT
	MOVLW	.9
	MOVWF	DIG_DSP3
	
END_RUT
	RETURN
			
DELAY_20MS
	MOVLW	.250
	MOVWF	CONT1
	MOVLW	.20
	MOVWF	CONT2
L1	NOP
	DECFSZ	CONT1,F
	GOTO	L1
L2	DECFSZ	CONT2,F
	GOTO	L2
	RETURN 

		
END
