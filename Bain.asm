    cblock 0x28
    Disp_FourthDigit ;???
    Disp_Cen
    Disp_Dec
    Disp_Uni
    endc
    cblock 0x38
    Work_Sign
    Work_Cen
    Work_Dec
    Work_Uni
    endc
    cblock 0x20
    Num1_Sign
    Num1_Cen
    Num1_Dec
    Num1_Uni
    endc
    cblock 0x30
    Num2_Sign
    Num2_Cen
    Num2_Dec
    Num2_Uni
    endc
    cblock 0x40
    Num3_Sign
    Num3_Cen
    Num3_Dec
    Num3_Uni
    endc
    cblock 0x50
    CurStep
    CalcTemp
    CalcTemp2
    CalcTemp3
    DelayCounter1
    DelayCounter2
    Deplete
    endc
    
    cblock 0x70
    Checksum1
    Checksum2
    Checksum3
    Checksum4
    endc
    ; A veces, la EEPROM puede tener basura en TODOS los registros.
    ; Para revisar si hay basura, vamos a usar un metodo llamado "checksum" pero cambiado.
    ; Osea, buscamos un codigo secreto secreto en una parte de la memoria EEPROM.
    ; Si no esta, automaticamente sobreescribimos las partes de la EEPROM que
    ; vamos a usar, asi no nos encontramos con algo inesperado.
    ; Si esta, entonces podemos cargar lo que queremos.
    ;; CREO QUE NI LO VOY A AGREGAR, CAGATE

;Input_M equ RB0
;Input_R equ RA4
;Input_G1 equ RA6
;Input_G2 equ RA7
;; En la simulacion de ejemplo,
; RA0 = 3
; RA1 = 4
; RA2 = 2
; RA3 = 1
EditDigit1 equ 3
EditDigit2 equ 2
EditDigit3 equ 0
EditDigit4 equ 1

#include <P16F628A.INC>
    __CONFIG 0x3F10 && _WDT_OFF && _LVP_OFF
    ORG 0
    goto START
    ORG 4
    goto INTERRUPT
    
INTERRUPT
    goto $ ; ???
    
GET_SEGMENTS
    addwf PCL,f
    retlw b'01111110' ; 0
    retlw b'00001100' ; 1
    retlw b'10110110' ; 2
    retlw b'10011110' ; 3
    retlw b'11001100' ; 4
    retlw b'11011010' ; 5
    retlw b'11111010' ; 6
    retlw b'00001110' ; 7
    retlw b'11111110' ; 8
    retlw b'11011110' ; 9
    retlw b'01010100' ; 0 - Fake 0  - 10 A
    retlw b'00000000' ;   - Blank   - 11 B
    retlw b'10000000' ; - - Minus   - 12 C
    retlw b'10101010' ; X - Error and on
    retlw b'10101010' ; X
    retlw b'10101010' ; X
    
EEPROM_Set MACRO thedata,theadr
    movf thedata,w
    movwf EEDATA
    movf theadr,w
    movwf EEADR
    ENDM
    
EEPROM_Save MACRO theadr
    movf theadr,w ; Toma el valor en esa direccion...
    bsf STATUS,RP0
    movwf EEDATA 
    movf theadr,w ; Como tambien usa la misma direccion ex di di di di
    movwf EEADR
    bsf EECON1,WREN ; Para activarlo
    call EEPROM_Write
    bcf EECON1,WREN ; Asi no escribimos por accidente
    bcf STATUS,RP0
    ENDM
    
EEPROM_Read ; La lectura toma un ciclo por alguna razon
    bsf STATUS,RP0
    movwf EEADR
    bsf EECON1,RD
    btfsc EECON1,RD ; Igual pongo esto, por si la EEPROM esta da�ada o cualquier wea weon wey
    goto $-1
    movf EEDATA,w ; Ya tenemos el dato!
    bcf STATUS,RP0
    return

    
START
    movlw 0x07
    movwf CMCON ; CMCON SE TIENE QUE ESTABLECER EN 7 PARA USAR TODO EL PORTA
    bsf STATUS,RP0
    clrf TRISA
    clrf TRISB
    bsf TRISB,RB0
    bsf TRISA,RA4
    bsf TRISA,RA6
    bsf TRISA,RA7
    bcf STATUS,RP0
    call NORMALIZE_WORK
    call DisplayWork
    bsf CurStep,2
    call StepNum1
    
WAIT_FOR_INPUT ; Loop para esperar que el usuario haga alguna mierda eeeeeeee
    call DELAYPROG
    call DisplayWork
    btfsc PORTB,RB0
    call Parse_M
    btfsc PORTA,RA4
    call Parse_R
    btfsc PORTA,RA6
    call Parse_G1
    btfsc PORTA,RA7
    call Parse_G2
    goto WAIT_FOR_INPUT
    
Parse_M
    ; oh shit nigga
    ; el usuario apreto la M de Mcambiar numero!!!!!!!!!!!!!!!!!!
    ; CurStep guarda el paso actual del programa
    rrf CurStep,f ; Lo rotamos hacia la rightrecha
    ; En que paso estamos ahora?
    btfsc CurStep,2
    goto RotateGood
    btfsc CurStep,1
    goto RotateGood+2
    btfsc CurStep,0
    goto RotateGood+4
    goto RotateBad
RotateGood 
    call StepNum1
    goto ParseMEnd
    call StepNum2
    goto ParseMEnd
    call StepResult
    goto ParseMEnd
RotateBad
    ; Si ninguno fue verdad...
    ; Vamos al principio
    clrf CurStep
    bsf CurStep,3 ; Ponemos un bit en posicion 3 que terminara siendo rotado
    goto Parse_M ; Otra vez, otra vez! Wheeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ParseMEnd
    btfss PORTB,RB0
    call StepPost
    return
    goto $-2
    
Parse_R
    clrf CurStep
    bsf CurStep,2
    clrf Work_Uni
    clrf Work_Dec
    clrf Work_Cen
    clrf Work_Sign
    clrf Num1_Uni
    clrf Num1_Dec
    clrf Num1_Cen
    clrf Num1_Sign
    clrf Num2_Uni
    clrf Num2_Dec
    clrf Num2_Cen
    clrf Num2_Sign
    call StepNum1
    return
    
    
    
    
Parse_G1
    btfsc CurStep,0
    return
    decf Work_Uni,f
    call NORMALIZE_WORK
    call PostWorkActions
    btfss PORTA,RA6
    return
    goto $-2
    
Parse_G2
    btfsc CurStep,0
    return
    incf Work_Uni,f
    call NORMALIZE_WORK
    call PostWorkActions
    btfss PORTA,RA7
    return
    goto $-2
    
    
    
    
PostWorkActions
    ; Tengo que ver que hacer con el signo
    call DisplayWork
    return
    
DisplayWork
    ; Mostrar un numero positivo es facil,
    ; pero en estos casos tengo que mostrar un numero negativo.
    ; Como hare, como hare...
    

    
    ; Revisemos el signo asi hacemos cosas
    btfsc Work_Sign,0
    goto NegateDigits
    goto RetainDigits
    
NegateDigits
    ; Los digitos son negativos, hacer algo para mostrarlos bien
    decf Work_Uni,f ; bazinga
    call NORMALIZE_WORK
    
    movlw .9
    movwf Disp_Uni
    movf Work_Uni,w
    subwf Disp_Uni,f
    movlw .9
    movwf Disp_Dec
    movf Work_Dec,w
    subwf Disp_Dec,f
    movlw .9
    movwf Disp_Cen
    movf Work_Cen,w
    subwf Disp_Cen,f
    
    incf Work_Uni,f
    call NORMALIZE_WORK
    goto PostNegate

RetainDigits
    ; Los digitos son normales, dejarlos asi como estan
    movf Work_Uni,w
    movwf Disp_Uni
    movf Work_Dec,w
    movwf Disp_Dec
    movf Work_Cen,w
    movwf Disp_Cen
    
PostNegate
    ; Ya que tenemos los numeros en su lugar, es hora de ubicar el MENOSSSS
    ; la concha de la lora
    
    btfsc Work_Sign,0 ; E MENO?
    goto $+3
    movlw .11 ; Blank
    goto $+2
    movlw .12 ; Minus
    
    movwf CalcTemp ; Lo guardamos un momento
    ; Tenemos que ver que display esta mas vacio para ubicar el simbolo!

PosTestMacro MACRO TestAddr
    ;<editor-fold defaultstate="collapsed" desc="Macrote de prueba! !! !!!">
    local EndMacro
    incf TestAddr,f ; Le agregamos 1...
    decfsz TestAddr,f ; Le quitamos 1.
	goto $+2
    goto EndMacro ; Si esta vacio (0), esta instruccion es ejecutada.
    ; De tal manera que se pone a revisar el siguiente numero
    ; Asi no dejamos huecos entre menos y numero actual, eh?
    
    ; No esta vacio? Terminamos aca, pongam� el meno en el anterior plis
    movf CalcTemp,w
    movwf TestAddr-1
    goto ImFuckingDone
EndMacro
    movlw .11
    movwf TestAddr-1
    ENDM ;</editor-fold>

    PosTestMacro Disp_Cen ; Probar posicion 3 para un menos en pos 4
    PosTestMacro Disp_Dec ; Probar posicion 2 para un menos en pos 3
    ; Probar la posicion 1 es al pedo, ponemos lo que sea ahora mismo
    movf CalcTemp,w
    movwf Disp_Dec
    
ImFuckingDone
    
CanWeDisplayTheseFuckingSegmentsNowPlease
    clrf PORTA
    movf Disp_Uni,w
    call GET_SEGMENTS
    movwf PORTB
    bsf PORTA,EditDigit4
    call DELAYPROG
    
    clrf PORTA
    movf Disp_Dec,w
    call GET_SEGMENTS
    movwf PORTB
    bsf PORTA,EditDigit3
    call DELAYPROG
    
    clrf PORTA
    movf Disp_Cen,w
    call GET_SEGMENTS
    movwf PORTB
    bsf PORTA,EditDigit2
    call DELAYPROG
    
    clrf PORTA
    movf Disp_FourthDigit,w
    call GET_SEGMENTS
    movwf PORTB
    bsf PORTA,EditDigit1
    call DELAYPROG
    
    return
    
NORMALIZE_WORK
    ; Noralizar - Hacer que los numeros de 1 digito sigan siendo de 1 digito.
    ; Osea, si un campo tiene 2 digitos,
    ; hacer matematica simple para ponerlos como 1 digito,
    ; y modificar el proximo digito como corresponda.
    
MACRO_NORM MACRO OriginAddr, DestAddr
    ;<editor-fold defaultstate="collapsed" desc="Macro para normalizacion">
    local isPos,isNeg,doN,okN,okdone,okdone2
    movf OriginAddr,w
    movwf CalcTemp
    movwf CalcTemp2
    movlw .128
    ; Hack: Vemos si el numero es "positivo" o "negativo".
    subwf CalcTemp2,f
    ; Si el numero es menor a 128, es positivo.
    ; Si es menor, osea mayor a 128,
    ; (ya que para llegar hasta ahi es mediante 0 - 1 for ej.)
    ; entonces sumamos por que es negativo. xdd
    
    ; Realisticamente no hay forma de, en una suma de 1 digito,
    ; sobrepasar 18 (9 + 9), o con negativo,
    ; sobrepasar -18 (-9 - 9)
    movlw .10
    btfsc STATUS,C
    goto isNeg
    goto isPos
    
isPos
    ; Al ser positivo, solo restare 10 una unica vez (18 - 10 = 8)
    subwf CalcTemp,f
    btfss STATUS,C
    goto okdone2
    ; Si hubo carry, es por que el numero es menor a 10
    ; Por ende, 9 o menor
    ; Por ende, el numero esta bien, y terminamos aca.
    
    ; Si no hubo carry, es por que es mayor a 10 (maximo 18)
    incf DestAddr,f ; Incrementamos 1 al proximo digito
    movf CalcTemp,w ; Movemos el numero restado...
    goto okdone
    
isNeg
    ; Al ser negativo, el numero puede
    ; llegar hasta -18 (-9 - 9)
    ; Por ende necesitare maximo 2 operaciones.
    ; (-18 + 10 = -8 + 10 = 2)
    ; Necesitare recursividad.
doN
    addwf CalcTemp,f ; Le damos 10 a nuestro temp
    btfsc STATUS,C ; Sobrepaso 255?
    goto okN ; Si no, saltar esto
    decf DestAddr,f ; oof
    goto doN ; Revisamos de nuevo
okN ; Estamos aca, significa que ya sobrepaso 255
    ; No queremos modificar este valor, pero si vamos a...
    decf DestAddr,f ; big oof
    movf CalcTemp,w

okdone
    movwf OriginAddr ; Hasta nunca, manga de forros
okdone2
    ENDM
    ;</editor-fold>
    
    MACRO_NORM Work_Uni, Work_Dec
    MACRO_NORM Work_Dec, Work_Cen
    MACRO_NORM Work_Cen, Work_Sign
    ; Ahora hay que arreglar el signo a algo legible
    clrf CalcTemp ; Limpito limpito
    btfsc Work_Sign,0 ; Saltar si bit 0 es 0, no saltar si es 1
    comf CalcTemp,f ; Si el bit era 1, llenemos este registro de unos
    movf CalcTemp,w
    movwf Work_Sign
    
    ; Listote
    return
    
    fill (nop),15 ; PCL se puede ir a la mierda conche su madre putogay tragasable
    
StepNum1 ; Venimos de StepResult
    ; No vamos a guardar el resultado, eso es pendejotudo
    
    ; Mover Num1 a Work
    movf Num1_Uni,w
    movwf Work_Uni
    movf Num1_Dec,w
    movwf Work_Dec
    movf Num1_Cen,w
    movwf Work_Cen
    movf Num1_Sign,w
    movwf Work_Sign
    return
    
StepNum2
    ; Mover Work a Num1
    movf Work_Uni,w
    movwf Num1_Uni
    movf Work_Dec,w
    movwf Num1_Dec
    movf Work_Cen,w
    movwf Num1_Cen
    movf Work_Sign,w
    movwf Num1_Sign
    
    ; Guardar todo Num1
    EEPROM_Save Num1_Uni
    EEPROM_Save Num1_Dec
    EEPROM_Save Num1_Cen
    EEPROM_Save Num1_Sign
    
    ; Mover Num2 a Work
    movf Num2_Uni,w
    movwf Work_Uni
    movf Num2_Dec,w
    movwf Work_Dec
    movf Num2_Cen,w
    movwf Work_Cen
    movf Num2_Sign,w
    movwf Work_Sign
    return
    
StepResult
    ; Mover Work a Num2
    movf Work_Uni,w
    movwf Num2_Uni
    movf Work_Dec,w
    movwf Num2_Dec
    movf Work_Cen,w
    movwf Num2_Cen
    movf Work_Sign,w
    movwf Num2_Sign
    
    ; Guardar todo Num2
    EEPROM_Save Num2_Uni
    EEPROM_Save Num2_Dec
    EEPROM_Save Num2_Cen
    EEPROM_Save Num2_Sign
    
    ; Hacer la operacion magica
    
    movf Num1_Uni,w
    movwf Work_Uni
    movf Num2_Uni,w
    subwf Work_Uni,f
    
    movf Num1_Dec,w
    movwf Work_Dec
    movf Num2_Dec,w
    subwf Work_Dec,f
    
    movf Num1_Cen,w
    movwf Work_Cen
    movf Num2_Cen,w
    subwf Work_Cen,f
    
    movf Num1_Sign,w
    movwf Work_Sign
    movf Num2_Sign,w
    subwf Work_Sign,f
    
    call NORMALIZE_WORK
    
    ; Guardar resultado en Num3
    movf Work_Uni,w
    movwf Num3_Uni
    movf Work_Dec,w
    movwf Num3_Dec
    movf Work_Cen,w
    movwf Num3_Cen
    movf Work_Sign,w
    movwf Num3_Sign
    
    return
    
StepPost
    EEPROM_Save CurStep
    return
    
    


DELAYPROG
    return
    
EEPROM_Write
    movlw 0x55
    movwf EECON2
    movlw 0xAA
    movwf EECON2
    bsf EECON1,WR
    btfsc EECON1,WR
    goto $-1
    return
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    end

