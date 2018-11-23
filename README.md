# TP-Final

Es un codigo que hice a ultimo momento desde cero.

El codigo usa un metodo de estados:
* El estado 1 te permite cargar el numero 1.
* El estado 2 te permite cargar el numero 2.
* El estado 3 automaticamente calcula el resultado y lo empuja a los registros de resultado.

Al ingresar los numeros, te es permitido cargar numeros negativos y la cuenta saldra bien.
No hice nada para prevenir que el usuario se pase de -999 o 999, ya sea por ingreso manual o cuenta normal. Creo que solo da una vuelta el numero.

El boton de reset no hace nada. OOPS

Cada numero esta compuesto por cuatro registros: El signo del numero (+ o -), centenas, decenas e unidades.
Los numeros estan denominados bajo el formato "XXX_YYY", donde XXX puede ser cosas como "Work" o "Num1", e "YYY" puede ser "Uni", "Dec", "Cen", "Sign" y otro mas.
Hay una funcion denominada "NORMALIZE_WORK", que lo que hace es tomar los cuatro numeros "Work" y los normaliza, es decir, si uno de los registros es considerado mayor a 9, le resta 10 para volverlo a un numero de una cifra y al numero siguiente se le suma 1, mientras que si es menor a 0, se le suma 10 y se le resta 1 al numero siguiente.
"Sign" representa el signo del numero. Si es 0x00, es positivo, si es 0xFF, es negativo.

El codigo guarda algunos numeros a la EEPROM, pero no agregue un metodo de carga.