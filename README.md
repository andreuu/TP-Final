# TP-Final

Hasta ahora, el programa solo hace:

* Incrementa numero1 con boton g1
* Decrementa numero1 con boton g2(numeros positivos)
* Guarda y resta los numeros con el boton M
* Guarda los numeros en variables dentro de la memoria ram
* Se muestra el signo solo en el 4to display


Falta:

* Guardar datos en la EEPROM
* Aprobar xd



Objetivo:

Realizar un programa que permita restar dos números decimales de tres dígitos en el tablero de acuerdo con la siguiente secuencia: 
* Se escribe un número en los displays. Con el botón G1 se incrementa el número del tablero y con el botón G2 se resta.  
* Se presiona el botón M para permitir el ingreso del segundo número.
* Se escribe el segundo número. Con el botón G1 se incrementa el número del tablero y con el botón G2 se resta.  
* Se presiona el botón M y se muestra el resultado haciendo N1-N2. Si el resultado da negativo, prender el segmento G del display que esté al lado del último dígito prendido. (Ej: si el resultado da -85, prender el segmento g del display 3, si da -9, prender el segmento g del display 2). 
* Si se presiona el botón R se comienza con el programa nuevamente. 
* Si en alguna parte de la secuencia de corta la alimentación, se deberá partir desde ese lugar cuando se conecte nuevamente. 

