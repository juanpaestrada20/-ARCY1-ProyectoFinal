; imprimir cadena;
; se recibe el texto que se imprimira
print macro cadena
	         LOCAL ETIQUETA
	ETIQUETA:
	         MOV   ah,09h    	; instruccion de impresion por la interrupcion 21h
	         MOV   dx,@data
	         MOV   ds,dx
	         lea   dx, cadena	; imprimimos la cadena
	         int   21h       	; fin de lal operacion
endm
 
; obtener char
; se utiliza para una pausa y que el usuario pueda leer el texto
getChar macro
	        mov ah,01h
	        int 21h
endm

; Obtiene la cadena de texto 
; buffer es donde se almacenara la cadena
getText macro buffer
	         LOCAL   CONTINUE, SALIR
	         PUSH    SI             	; guardar lo que tengo en si
	         PUSH    AX             	; guardar lo que tengo en ax

	         xor     si,si          	; limpiar el registro si
	CONTINUE:
	         getChar                	; obtiene un caracter
	         cmp     al,0dh         	; verifica que sea un enter para dejar de aceptar
	         je      SALIR          	; si es enter deja de recibir la entrada
	         mov     buffer[si],al  	; almacena el caracter recibido
	         inc     si             	; incremento la posicion del array
	         jmp     CONTINUE       	; continuo recibiendo carcteres

	SALIR:   
	         mov     al,'$'         	; Coloco final de cadena
	         mov     buffer[si],al  	; almaceno final de cadena

	         POP     AX             	; recuparar valor ax
	         POP     SI             	; recuperar valor si
endm

; macro para obtener la ruta
getRuta macro buffer
	        LOCAL   INICIO,FIN
	        xor     si,si         	; limpiamos el registro si
	INICIO: 
	        getChar               	; obtenemos letra
	        cmp     al,0dh        	; si enter terminamos
	        je      FIN
	        mov     buffer[si],al 	; concatenamos letra ingresada
	        inc     si
	        jmp     INICIO
	FIN:    
	        mov     buffer[si],00h	; finalizamos de obtener la rua
endm

; Crea el archivo
; buffer es el nombre del archivo
; handle es el manejador del archivo
createFile macro buffer, handle
	           mov ah,3ch    	; genera el archivo
	           mov cx,00h    	; limpia cx
	           lea dx,buffer 	; le pone nombre al archivo creado
	           int 21h       	; Finaliza el proceso
	           mov handle,ax 	;
	           jc  ErrorCrear	; error por si no se crea el archivo
endm


; Escritura de archivos
; numbytes es el tamaño de la cadena que queremos escribir
; buffer es la cadena que queremos escribir
; handle es el manejador de archivos
writeFile macro numbytes, buffer, handle
	          mov ah, 40h      	; Opercion escritura de archivo
	          mov bx,handle    	; a bx le colocamos el manejador
	          mov cx, numbytes 	; colocamos de contador el tamaño de lo que se escribira
	          lea dx,buffer    	; lo guardamos en dx
	          int 21h          	; fin de opoeracion de escritura
	          jc  ErrorEscribir	; Error por si no se puede escribir en el archivo
endm

; Abre archivos
; ruta es la ruta del archivo que queramos abrir
; handle es para el manejador de archivos del programa
openFile macro ruta, handle
	         mov ah,3dh    	; operacion para abrir archivos
	         mov al,10b    	; operacion de escritura
	         lea dx,ruta   	; obtiene lo que tiene el archivo
	         int 21h       	; fin de operacion
	         mov handle,ax 	; limpia el handle
	         jc  ErrorAbrir	; error por si no puede abrir el archivo
endm

; Cerrar archivo
; handle es el manejador del archivo
closeFile macro handle
	          mov ah,3eh   	; Operacion de cierre de un archivo abierto
	          mov handle,bx	; limpiar el manejador
	          int 21h      	; Fin de operacion
endm

; Leer Archivo
; numbytes -> tamaño del archivo
; buffer -> donde se almacenara lo del archivo
; handle -> manejador de archivos
readFile macro numbytes,buffer,handle
	         mov ah,3fh     	; Lectura de archivo
	         mov bx,handle  	; utilizar manejador
	         mov cx,numbytes	; tamaño del archivo
	         lea dx,buffer  	; lo leido lo envia a dx
	         int 21h        	; fin de operacion
	         jc  ErrorLeer  	; mensaje de error
endm

; Limpiar variables
; value -> variable a limpiar
; numBytes -> tamaño variable 
clean macro value, numBytes
	           local       RepeatLoop
	           pushRecords
	           xor         si, si
	           xor         cx, cx
	           mov         cx, numBytes
	RepeatLoop:
	           mov         value[si], '$'
	           inc         si
	           Loop        RepeatLoop
	           popRecords
endm

; guardar los registros que tenemos
; este macro se utilizara al momento de hacer 
; algun analisis y no perdamos los datos ya 
; almacenados
pushRecords macro
	            push ax
	            push bx
	            push cx
	            push dx
	            push si
	            push di
endm

; sacar los registros que habiamos guarado
popRecords macro
	           pop di
	           pop si
	           pop dx
	           pop cx
	           pop bx
	           pop ax
endm

; Obtener fecha
; buffer es donde se almacenara 
getFecha macro buffer
	         xor ax, ax         	; limpiar el registro ax
	         xor bx, bx         	; limpiar el registro bx
	         mov ah, 2ah        	; operacion para obtener fecha
	         int 21h            	; fin de operacion

	         mov di,0           	; limpiar el registro di
	         mov al,dl          	; trnas
	         bcd buffer

	         inc di
	         mov al, dh
	         bcd buffer

	         inc di
	         mov buffer[di], 32h
	         inc di
	         mov buffer[di], 30h
	         inc di
	         mov buffer[di], 32h
	         inc di
	         mov buffer[di], 30h

endm

getHora macro buffer
	        xor ax, ax
	        xor bx, bx
	        mov ah, 2ch
	        int 21h

	        mov di,0
	        mov al, ch
	        bcd buffer

	        inc di
	        mov al, cl
	        bcd buffer

	        inc di
	        mov al, dh
	        bcd buffer
	
endm

bcd macro entrada
	    push dx
	    xor  dx,dx
	    mov  dl,al
	    xor  ax,ax
	    mov  bl,0ah
	    mov  al,dl
	    div  bl
	    push ax
	    add  al,30h
	    mov  entrada[di], al
	    inc  di

	    pop  ax
	    add  ah,30h
	    mov  entrada[di], ah
	    inc  di
	    pop  dx

endm

to_string macro string
	            LOCAL NEGATIVO, DIVIDIR,TERMINARDIV,CONV,FINDIV
	            PUSH  si
	            PUSH  di
	;xor ax,ax
	            xor   dx, dx
	            xor   bx, bx
	            xor   cx,cx
	            xor   si,si
	            xor   di,di
	;mov ax,numero
	            test  ax,1000000000000000
	            jnz   NEGATIVO
	            jmp   DIVIDIR

	NEGATIVO:   
	            neg   ax
	            mov   string[di], 45
	            inc   di

	DIVIDIR:    
	            mov   cx, 10d
	            div   cx
	            push  dx
	            xor   dx,dx
	            inc   si
	            cmp   ax,00h
	            je    TERMINARDIV
	            jmp   DIVIDIR

	TERMINARDIV:
	            mov   cx, si
	            xor   si,si
	            mov   si,di
	            xor   di,di

	CONV:       
	            pop   dx
	            add   dl,48d
	            mov   string[si],dl
	            inc   si
	            loop  conv
	            mov   dl, 36d
	            mov   string[si],dl

	FINDIV:     
	            POP   si
	            POP   di
	            nop

endm


to_int macro string
	           LOCAL CONVERTSI, FINSI, ACTIVARC2,ULTIMACION,C2
	           PUSH  si
	           PUSH  cx
	           xor   si,si
	           xor   cx,cx
	           xor   ax,ax

	CONVERTSI: 
	           xor   dx,dx
	           xor   bx,bx
	           mov   bx,10d
	           mov   cl, string[si]
	           cmp   cl,45
	           je    ACTIVARC2
	           cmp   cl,48
	           jl    ULTIMACION
	           cmp   cl,57
	           jg    ULTIMACION
	           sub   cl,48
	           mul   bx
	           add   ax,cx
	           inc   si
	           jmp   CONVERTSI

	ACTIVARC2: 
	           mov   varAux,1
	           inc   si
	           jmp   CONVERTSI

	ULTIMACION:
	           cmp   varAux,1
	           je    C2
	           jmp   FINSI

	C2:        
	           neg   ax
	FINSI:     
	           mov   varAux,0
	           POP   cx
	           POP   si
	           nop
endm

;guardar en un arreglo
saveOnArray macro auxCadena, array
	            LOCAL ASIGNACION, FIN, POSICION
	            xor   si, si
	            xor   di, di
				
	POSICION:   
	            mov   bl, array[di]            	; caracter al registro bl
	            cmp   bl, '$'                  	; fin de cadena
	            je    ASIGNACION
	            inc   di
	            jmp   POSICION

	ASIGNACION: 
	            mov   bl, auxCadena[si]        	; caracter al registro bl
	            cmp   bl, '$'                  	; fin de cadena
	            je    FIN
	            mov   array[di], bl
	            inc   di
	            inc   si
	            jmp   ASIGNACION

	FIN:        
endm

; CARGA DE DATOS INICIALES AL PROGRAMA
;leemos los archivos que cargaran los datos a nuestra aplicacion
lecturaArchivos macro
	; limpiamos nuestro buffer de lectura
	                clean      bufferLectura, SIZEOF bufferLectura
	; iniciamos leyendo los usuarios
	                openFile   rutaUsuarios, handleFichero
	                readFile   SIZEOF bufferLectura, bufferLectura, handleFichero
	                closeFile  handleFichero
	; ya con los usuarios iniciamos a la separacion
	                readUsers  bufferLectura
	; limpiamos nuestro buffer de lectura
	                clean      bufferLectura, SIZEOF bufferLectura
	; iniciamos leyendo los puntajes
	                openFile   rutaPunteos, handleFichero
	                readFile   SIZEOF bufferLectura, bufferLectura, handleFichero
	                closeFile  handleFichero
	; ya con los puntajes leidos procedemos a almacenarlos
	                readPoints bufferLectura
	; finalizamos con la carga inicial
					
endm

;Lectura de usuarios
readUsers macro buffer
	          LOCAL       GETUSER, INCREMENT, CONTINUE, END
	          xor         si, si
	          xor         di, di
	          clean       auxCadena, SIZEOF auxCadena

	;recorremos caracter por caracter la entrada
	GETUSER:  
	          mov         bl, buffer[si]
	; comparamos si hemos llegado al fin de cadena
	          cmp         bl, '$'
	; si es el final terminamos de analizar
	          je          END
	; si no es final de cadena, vemos si ya finalizamos de obtener el usuario
	          cmp         bl, ';'
	; si cumple continuamos a guardar el dato
	          je          CONTINUE
	; si no es ninguno de los anteriores vamos guardando la cadena
	          mov         auxCadena[di], bl
	; continuamos a incrementar nuestros contadores
	          jmp         INCREMENT

	INCREMENT:
	; incrementamos los indices que estamos utilizando
	          inc         si
	          inc         di
	; regresamos para obtener el usuario
	          jmp         GETUSER

	CONTINUE: 
	; guardamos nuestros registros en la pila
	          pushRecords
	; guardamos el usuario y contrasena
	          saveOnArray auxCadena, listaUsuarios
	; agregamos suparador a la lista
	          mov         bl, '%'
	          mov         listaUsuarios[di], bl
	; recuperamos nuestros registros
	          popRecords
	; incrementamos si para saltar el caracter ';' , el salto de linea y retorno de carro
	          inc         si
	          inc         si
	          inc         si
	; limpiamos nuestra variable auxiliar y el indice que utilizamos con este
	          clean       auxCadena, SIZEOF auxCadena
	          xor         di, di
	;continuamos con el analisis de la carga
	          jmp         GETUSER

	END:      
	; esta es nuestra etiqueta de salida por lo cual no hacemos nada

endm

;lectura de puntajes
readPoints macro buffer
	           LOCAL       GETRECORD, CONTINUE, INCREMENT, END
	;limpiamos registros que utilizaremos de indices
	           xor         si, si
	           xor         di, di
	           clean       auxCadena, SIZEOF auxCadena
	; limpiamos variable auxiliar
	GETRECORD: 
	           mov         bl, buffer[si]
	; comparamos si hemos llegado al fin de cadena
	           cmp         bl, '$'
	; si es el final terminamos de analizar
	           je          END
	; si no es final de cadena, vemos si ya finalizamos de obtener el resultado
	           cmp         bl, ';'
	; si cumple continuamos a almacenar el dato obtenido
	           je          CONTINUE
	; si no es ninguno de los anteriores vamos guardando la cadena
	           mov         auxCadena[di], bl
	; continuamos a incrementar nuestros contadores
	           jmp         INCREMENT

	INCREMENT: 
	; incrementamos los indices que estamos utilizando
	           inc         si
	           inc         di
	; regresamos para obtener el usuario
	           jmp         GETRECORD

	CONTINUE:  
	; guardamos nuestros registros en la pila
	           pushRecords
	; guardamos el usuario y contrasena
	           saveOnArray auxCadena, listaPunteos
	; agregamos suparador a la lista
	           mov         bl, '%'
	           mov         listaPunteos[di], '%'
	; recuperamos nuestros registros
	           popRecords
	; incrementamos si para saltar el caracter ';' , el salto de linea y retorno de carro
	           inc         si
	           inc         si
	           inc         si
	; limpiamos nuestra variable auxiliar y el indice que utilizamos con este
	           clean       auxCadena, SIZEOF auxCadena
	           xor         di, di
	;continuamos con el analisis de la carga
	           jmp         GETRECORD

	END:       
	; esta es nuestra etiqueta de salida por lo cual no hacemos nada
endm

; VERIFICACION DE USUARIO Y CONTASEÑA
;verificacion de usuario 
verifyUser macro user
	           LOCAL     RECORRER, VALIDAR, ERRORSIZE, EXISTENCIA , SALIR, ERROR, ADMIN
	; Limpiamos los registros que utilizaremos
	           xor       si, si
	           xor       di, di
	           xor       cx, cx
	; contaremos la cantidad de caracteres que se han ingresado
	RECORRER:  
	           mov       bl, user[si]
	           cmp       bl, '$'
	; si llegamos al fin de cadena verificamos cuantos caracteres fueron contados
	           je        VALIDAR
	           inc       si
	           jmp       RECORRER

	VALIDAR:   
	; si el registro si >= 7 significa que ingreso 8 o mas caracteres
	           cmp       si, 7
	; error de tamaño
	           jg        ERRORSIZE
	; si cumple con el tamaño verificamos que no exista el usuario
	           jmp       EXISTENCIA
	
	EXISTENCIA:
	; enviamos a comparar el usuario con los ya existentes
	           userExist user
	; como primera instancia vemos si el usuario no es igual que el admin
	           xor       si, si
	           cmp       bl, 'Y'
	           je        ERROR
	           jmp       ADMIN
	ERRORSIZE: 
	           print     msmError5
	           jmp       RegistroSesion

	ERROR:     
	           print     msmError6
	           jmp       RegistroSesion

	ADMIN:     
	           xor       si,si
	           xor       di, di
	           xor       cx, cx
	           mov       cx, 8
	           lea       si, adminUser
	           lea       di, user
	           repe      cmpsb
	           je        ERROR
	           jmp       SALIR
	
	SALIR:     

endm

; Verifico que no exita el nombre de usuario que dio el usuario
userExist macro user
	           LOCAL GETLIST, INCREMENT, COMPARE, EQUALS, NEXT, END, ACCEPTED, INCREMENT2
	; limpio los registros que utilizare
	           xor   si, si
	           xor   di, di
	           xor   bx, bx

	GETLIST:   
	           mov   bl, listaUsuarios[si]
	; comparo si es el separador entre usuarios
	           cmp   bl, ':'
	; si lo es me dirijo a comparar el usuario
	           je    COMPARE
	; sino compara si es el fin de cadena
	           cmp   bl, '$'
	; si llega aca significa que no existe el usuario
	           je    ACCEPTED
	; si no es ninguno continuo a almacenar a una variable axiliar para luego separar
	           mov   auxCadena[di], bl
	; vamos a incementar los registros
	           jmp   INCREMENT

	INCREMENT: 
	; incrementamos los indices que estamos utilizando
	           inc   si
	           inc   di
	           jmp   GETLIST

	COMPARE:   
	; guardamos el indice que usamos en la lsita de usuarios
	           push  si
	; cantidad de caracteres a comparar
	           xor   cx, cx
	           mov   cx, di
	           mov   ax, ds
	           mov   es, ax
	; limpiamos los registros para realizar la comparacion
	           xor   si, si
	           xor   di, di
	; enviamos las cadenas a comparar
	           lea   si, user
	           lea   di, auxCadena
	; realizamos la comparacion
	           repe  cmpsb
	; si es igual  nos vamos a EQUALS
	           je    EQUALS
	; terminasmos de comparar las cadenas y recuperamos el valor de si
	           pop   si
	; si no es igual salteamos la contasena
	           jmp   NEXT

	EQUALS:    
	; terminasmos de comparar las cadenas y recuperamos el valor de si
	           pop   si
	; seteamos en bl para indicar que si existe ese usuario
	           mov   bl, 'Y'
	; salimos de la macro
	           jmp   END

	NEXT:      
	; limpio lo que necesitara para almacenar un nuevo usario
	           xor   di, di
	           clean auxCadena, SIZEOF auxCadena
	           mov   bl, listaUsuarios[si]
	; si encuento '%' ya puedo buscar otro usuaria
	           cmp   bl, '%'
	           je    INCREMENT2
	           inc   si
	; contiunuamos a obtener el siguiente usuario a comparar
	           jmp   NEXT

	INCREMENT2:
	; nos salteamos '%'
	           inc   si
	           jmp   GETLIST

	ACCEPTED:  
	; setamos N a bl para indicar que no existe el usuario ingresado
	           mov   bl, 'N'
	           jmp   END

	END:       

endm

;verificamos que la contraseña sean solo numeros
verifyPass macro pass
	           LOCAL RECORRER, INCORRECT, END, COMPARE, ERROR
	           xor   si, si
	           xor   di, di

	; recorremos caracter por caracter  para verificar que solo sean numeros
	RECORRER:  
	           mov   bl, pass[si]
	; verificamos que sea el fin de cadena
	           cmp   bl, '$'
	           je    COMPARE
	; comparamos que no sea menor que el ascii de '0'
	           cmp   bl, '0'
	           jl    INCORRECT
	; comparamos que no sea mayor que el ascii de '9'
	           cmp   bl, '9'
	           jg    INCORRECT
	           inc   si
	           jmp   RECORRER

	INCORRECT: 
	           print msmError7
	           print salto
	           jmp   Contra

	COMPARE:   
	           cmp   si, 4
	           je    END
	           jmp   ERROR

	ERROR:     
	           print msmError8
	           print salto
	           jmp   Contra
	
	END:       

endm

; agregamos el nuevo usuario con su contraseña
addNewUser macro user, pass
	; guardamos nuestros registros en la pila
	           pushRecords
	; guardamos el usuario
	           saveOnArray user, listaUsuarios
	; agregamos suparador de usuario
	           mov         bl, ':'
	           mov         listaUsuarios[di], bl
	; guardamos el usuario
	           saveOnArray pass, listaUsuarios
	; agregamos suparador de usuario y contra
	           mov         bl, '%'
	           mov         listaUsuarios[di], bl
	; recuperamos nuestros registros
	           popRecords

	           print       listaUsuarios
endm

;para hacer el login verificamos si existe el usuario o es el admin
login macro user, pass
	            LOCAL      SEARCH, CONTRA, ADMIN, ADMINCONTRA,NOUSER, COMPARE, WRONGPASS, ACCESS, ORDER
	            xor        si, si
	            xor        di, di
	            clean      auxCadena, SIZEOF auxCadena

	SEARCH:     
	; verificamos que el usuario exista
	            userExist  user
	; limpiamos lo que usaremos para obtener contraseña
	            xor        di, di
	            clean      auxCadena, SIZEOF auxCadena
	; si existe el usurio bl contendra 'Y' y sino contrndra 'N'
	            cmp        bl, 'Y'
	; pasamos a buscar la contraseña del usuario
	            je         CONTRA
	; si no se encuentra el usuario vemos si es el usuario del administrador
	            jmp        ADMIN

	ADMIN:      
	; limpiamos los registros para comparar
	            xor        si,si
	            xor        di, di
	            xor        cx, cx
	; colocamos la contidad de caracteres a comparar
	            mov        cx, 8
	            lea        si, adminUser
	            lea        di, user
	            repe       cmpsb
	; si es el usuario pasamos a comparar
	            je         ADMINCONTRA
	; si no es el admin mandamos error de usuario que no existe
	            jmp        NOUSER
	
	; recorremos la lista para obtener la contraseña
	CONTRA:     
	            inc        si
	            mov        bl, listaUsuarios[si]
	; verificamos si terminamos de recuperar la contraseña
	            cmp        bl , '%'
	; nos vamos a comparar contraseña
	            je         COMPARE
	            mov        auxCadena[di], bl
	            inc        di
	            jmp        CONTRA
	          
	NOUSER:     
	;si no existe el usuario enviamos mensaje y regresamos al menu
	            print      msmError9
	            print      salto
	            jmp        Menu

	ADMINCONTRA:
	; limpiamos registros para la comparacion
	            xor        si,si
	            xor        di, di
	            xor        cx, cx
	            mov        cx, 5
	            lea        si, adminPass
	            lea        di, pass
	            repe       cmpsb
	; si es el admin nos dirigimos al menu del administrador
	            je         ORDER
	            jmp        WRONGPASS

	ORDER:      
	            getNumbers listaPunteos
	            jmp        AdminMenu

	COMPARE:    
	; limpiamos registros para la comparacion
	            xor        si,si
	            xor        di, di
	            xor        cx, cx
	; la cantidad de caracteres a comparar es 5
	            mov        cx, 5
	            lea        si, auxCadena
	            lea        di, pass
	            repe       cmpsb
	; si la conntraseña del usuario coincide con la del usuario accedemos al juego
	            je         ACCESS
	            jmp        WRONGPASS

	WRONGPASS:  
	; usuario valido pero contraseña incorrecta
	            print      msmError10
	            print      salto
	            jmp        IniciarSesion

	ACCESS:     
	            print      aunNo
	            getChar
	            jmp        Menu
endm


; ORDENAMIENTOS
; obtener los puntos de los registros que tenemos
getNumbers macro punteos
	           LOCAL          GETRECORD, NEXT, END, SEPARATE
	; registro para llevar el indice de la lista de punteos
	           xor            si, si
	; registro para llevar el indice de los puntos ingresados
	           xor            di, di
	; contador que utilizare para saber cuando registros tengo
	           xor            cx, cx
	; limpiamos variable auxiliar
	           clean          auxCadena, SIZEOF auxCadena

	GETRECORD: 
	           mov            bl, punteos[si]
	; verificamos final de cadena
	           cmp            bl, '$'
	           je             END
	; comparamos si terminamos de obtener el registro
	           cmp            bl, '%'
	           je             SEPARATE
	; sino almacenamos el registro en variable auxiliar
	           mov            auxCadena[di], bl
	           inc            si
	           inc            di
	           jmp            GETRECORD

	SEPARATE:  
	           pushRecords
	; separamos los registros de puntos y tiempo
	           separateRecord auxCadena
	; conventimos el punteo a numero
	           to_int         punteo
	           mov            punteoAux, ax
	; conventimos el punteo a numero
	           to_int         tiempo
	           mov            tiempoAux, ax
	           popRecords
	; colocames en ax la la cantidad anterior
	           mov            ax, cx
	           mov            bx, 2
	; multiplicamos ax * 2 para obtener la posicion donde almacenar
	           imul           bx
	           xor            di, di
	; colocamos la posicion obtenida en di
	           mov            di, ax
	; posicion di almacenamos el valor
	           xor            ax, ax
	           mov            ax, punteoAux
	           mov            puntajes[di], ax
	           xor            ax, ax
	           mov            ax, tiempoAux
	           mov            tiempos[di], ax
	; incrementamos el contador de registros encontrados
	           inc            cx
	; dirigimos a obtener el siguiente registro
	           jmp            NEXT

	NEXT:      
	; salteamos es '%'
	           inc            si
	; limpiamos los registros para recorrer la cadena auxiliar
	           xor            di, di
	; limiamos auxCadena
	           clean          auxCadena, SIZEOF auxCadena
	           jmp            GETRECORD

	END:       

endm 

; recorrer el registro para separar
separateRecord macro registro
	               LOCAL USUARIO, NIVEL, PUNTOS, TIEMPOS, NEXT, END
	; registro que llevara el indice del registro obtenido
	               xor   si, si
	; registro que llevara el indice de donde almacenaremos los valores
	               xor   di, di
	               clean punteo, SIZEOF punteo
	               clean tiempo, SIZEOF tiempo


	USUARIO:       
	               mov   bl, registro[si]
	; comparamos para ver si terminamos de obtener el usuario
	               cmp   bl, ','
	               je    NIVEL
	; incrementamos indicie
	               inc   si
	               jmp   USUARIO

	NIVEL:         
	; incrementamos indicie para saltar ','
	               inc   si
	               mov   bl, registro[si]
	; comparamos para ver si terminamos de obtener el nivel
	               cmp   bl, ','
	               je    PUNTOS
	               jmp   NIVEL

	PUNTOS:        
	; incrementamos indicie para saltar ','
	               inc   si
	               mov   bl, registro[si]
	; comparamos para ver si terminamos de obtener el punteo
	               cmp   bl, ','
	               je    NEXT
	; si no es coma almacenamos el punteo
	               mov   punteo[di], bl
	               inc   di
	               jmp   PUNTOS

	NEXT:          
	; reiniciamos di para poder llevar el registro del tiempo
	               xor   di,di
	               jmp   TIEMPOS

	TIEMPOS:       
	; incrementamos indicie para saltar ','
	               inc   si
	               mov   bl, registro[si]
	; comparamos para ver si terminamos de obtener el tiempo
	               cmp   bl, '$'
	               je    END
	; si no es coma almacenamos el tiempo
	               mov   tiempo[di], bl
	               inc   di
	               jmp   TIEMPOS

	END:           

endm










