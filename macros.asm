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
	            LOCAL         SEARCH, CONTRA, ADMIN, ADMINCONTRA,NOUSER, COMPARE, WRONGPASS, ACCESS, ORDER
	            xor           si, si
	            xor           di, di
	            clean         auxCadena, SIZEOF auxCadena
	            clean         punteo, SIZEOF punteo
	            mov           punteoAux, 00h
	; clean         puntajes SIZEOF puntajes
	; clean         orderedPoints, SIZEOF orderedPoints
	            clean         orderedUsersPoints, SIZEOF orderedUsersPoints
	;clean         positionsListPoints, SIZEOF positionsListPoints
	            clean         tiempo, SIZEOF tiempo
	            mov           tiempoAux, 00h
	;clean         tiempos SIZEOF tiempos
	; clean         orderedTimes, SIZEOF orderedTimes
	            clean         orderedUsersTimes, SIZEOF orderedUsersTimes
	;clean         positionsListTimes, SIZEOF positionsListTimes

	SEARCH:     
	; verificamos que el usuario exista
	            userExist     user
	; limpiamos lo que usaremos para obtener contraseña
	            xor           di, di
	            clean         auxCadena, SIZEOF auxCadena
	; si existe el usurio bl contendra 'Y' y sino contrndra 'N'
	            cmp           bl, 'Y'
	; pasamos a buscar la contraseña del usuario
	            je            CONTRA
	; si no se encuentra el usuario vemos si es el usuario del administrador
	            jmp           ADMIN

	ADMIN:      
	; limpiamos los registros para comparar
	            xor           si,si
	            xor           di, di
	            xor           cx, cx
	; colocamos la contidad de caracteres a comparar
	            mov           cx, 8
	            lea           si, adminUser
	            lea           di, user
	            repe          cmpsb
	; si es el usuario pasamos a comparar
	            je            ADMINCONTRA
	; si no es el admin mandamos error de usuario que no existe
	            jmp           NOUSER
	
	; recorremos la lista para obtener la contraseña
	CONTRA:     
	            inc           si
	            mov           bl, listaUsuarios[si]
	; verificamos si terminamos de recuperar la contraseña
	            cmp           bl , '%'
	; nos vamos a comparar contraseña
	            je            COMPARE
	            mov           auxCadena[di], bl
	            inc           di
	            jmp           CONTRA
	          
	NOUSER:     
	;si no existe el usuario enviamos mensaje y regresamos al menu
	            print         msmError9
	            print         salto
	            jmp           Menu

	ADMINCONTRA:
	; limpiamos registros para la comparacion
	            xor           si,si
	            xor           di, di
	            xor           cx, cx
	            mov           cx, 5
	            lea           si, adminPass
	            lea           di, pass
	            repe          cmpsb
	; si es el admin nos dirigimos al menu del administrador
	            je            ORDER
	            jmp           WRONGPASS

	ORDER:      
	; obtengo los puntajes y tiempos
	            getNumbers    listaPunteos
	; llenamos el arreglo para saber que posiciones puedo mover
	            fillpositions positionsListPoints
	            transferArray positionsListPoints, positionsListTimes
	; transferimos el arreglo de punteos para ordenar
	            transferArray puntajes, orderedPoints
	; ordenamos los puntos y posiciones nuevas
	            BubbleSort    orderedPoints, positionsListPoints
	            orderRecords  listaPunteos, orderedUsersPoints, positionsListPoints
	; transferimos el arreglo de tiempos para ordenar
	            inc           cont
	            transferArray tiempos, orderedTimes
	            BubbleSort    orderedTimes, positionsListTimes
	            orderRecords  listaPunteos, orderedUsersTimes, positionsListTimes
	            jmp           AdminMenu

	COMPARE:    
	; limpiamos registros para la comparacion
	            xor           si,si
	            xor           di, di
	            xor           cx, cx
	; la cantidad de caracteres a comparar es 5
	            mov           cx, 5
	            lea           si, auxCadena
	            lea           di, pass
	            repe          cmpsb
	; si la conntraseña del usuario coincide con la del usuario accedemos al juego
	            je            ACCESS
	            jmp           WRONGPASS

	WRONGPASS:  
	; usuario valido pero contraseña incorrecta
	            print         msmError10
	            print         salto
	            jmp           IniciarSesion

	ACCESS:     
	            print         aunNo
	            getChar
	            jmp           Menu
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
	           mov            cont, 00h

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
	           mov            cont, cx

endm 

; recorrer el registro para separar
separateRecord macro registro
	               LOCAL USUARIO, NIVEL, PUNTOS, TIEMPOS, NEXT, END, SIGUIENTE, SIGUIENTE2
	; registro que llevara el indice del registro obtenido
	               xor   si, si
	; registro que llevara el indice de donde almacenaremos los valores
	               xor   di, di
	               clean user, SIZEOF user
	               clean level, SIZEOF level
	               clean punteo, SIZEOF punteo
	               clean tiempo, SIZEOF tiempo


	USUARIO:       
	               mov   bl, registro[si]
	; comparamos para ver si terminamos de obtener el usuario
	               cmp   bl, ','
	               je    SIGUIENTE
	               mov   user[di], bl
	               inc   di
	; incrementamos indice
	               inc   si
	               jmp   USUARIO

	SIGUIENTE:     
	               xor   di, di
	               jmp   NIVEL

	NIVEL:         
	; incrementamos indicie para saltar ','
	               inc   si
	               mov   bl, registro[si]
	; comparamos para ver si terminamos de obtener el nivel
	               cmp   bl, ','
	               je    SIGUIENTE2
	               mov   level[di], bl
	               inc   di
	               jmp   NIVEL

	SIGUIENTE2:    
	               clean punteo, SIZEOF punteo
	               xor   di, di
	               jmp   PUNTOS

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

; transferimos a la lista para odenar 
transferArray macro origin, destiny
	              LOCAL RECORRER, INCREMENT, END
	              xor   si, si
	              xor   ax, ax

	RECORRER:     
	              mov   ax, origin[si]
	; comparo fin de arreglo
	              cmp   ax, '$'
	              je    END
	; si no es el ultimo muevo el valor
	              mov   destiny[si], ax
	              jmp   INCREMENT

	INCREMENT:    
	; aumento 2 posiciones
	              inc   si
	              inc   si
	; limpio ax
	              xor   ax, ax
	; continuo reocrriendo
	              jmp   RECORRER

	END:          


endm

; imprimir  arreglo
printArray macro array
	           LOCAL     GETNUMBER, INCREMENT, END
	; lleva la posicion del arreglo
	           xor       si, si
	           clean     auxCadena, SIZEOF auxCadena

	GETNUMBER: 
	           mov       ax, array[si]
	; comparo si es el fin de cadena
	           cmp       ax, '$'
	           je        END
	; sino imprimo
	           push      si
	           to_string auxCadena
	           print     auxCadena
	           print     salto
	           pop       si
	           jmp       INCREMENT

	INCREMENT: 
	; incremento si dos veces
	           inc       si
	           inc       si
	; limpio cadena auxiliar
	           clean     auxCadena, SIZEOF auxCadena
	           jmp       GETNUMBER

	END:       

endm

; ORDENAMIENTOS SIN GRAFICA
; BUBBLE SORT
BubbleSort macro array, array2
	           LOCAL JUMP3, JUMP2, JUMP1, SWAP
	           dec   cont
	           xor   di, di
	           mov   cont2, 00h
	JUMP3:     
	           mov   si, di
	           inc   si
	           inc   si
	JUMP2:     
	           mov   ax, array[di]            	; al
	           mov   dx, array[si]
	           cmp   dx, '$'
	           je    JUMP1                    	; ah
	
	SWAP:      
	           cmp   ax, dx
	           jge   JUMP1
	           mov   array[di], dx
	           mov   array[si], ax
	           xor   ax, ax
	           xor   bx, bx
	           mov   ax, array2[di]
	           mov   bx, array2[si]
	           mov   array2[di], bx
	           mov   array2[si], ax

	JUMP1:     
	           inc   si
	           inc   si
	           cmp   si, SIZEOF array
	           jnz   JUMP2
	           inc   di
	           inc   di
	           inc   cont2
	           mov   cx, cont2
	           cmp   cx, cont
	           jnz   JUMP3
endm

; llenamos el arreglo auxiliar para 
fillpositions macro array
	              LOCAL RECORRER, END
	; limipiar registro que llevara la posicion del arreglo
	              xor   si, si
	; limpiamos el registro que llevara el numero
	              xor   ax, ax
	; inicializamos el contador en 0
	              mov   cont2, 00h

	RECORRER:     
	; colocamos el numero en el arreglo
	              mov   array[si], ax
	; incrementamos el indice
	              inc   si
	              inc   si
	; incrementamos el numero
	              inc   ax
	; incrementamos cantidad ingresada
	              inc   cont2
	; comparamos que sea la misma cantidad de datos
	              mov   cx, cont
	              cmp   cont2, cx
	              jge   END
	              jmp   RECORRER

	END:          

endm

; ordenear los registros completos
orderRecords macro origen, destino, posiciones
	             LOCAL       RECORRER, COMPARAR, AUMENTAR, END, RESTART, AGREGAR
	; posicion de array de origen
	             xor         si, si
	; posicion de array destino
	             xor         di, di
	; iniciar contador
	             xor         cx, cx
	             xor         dx, dx
	             mov         cont2, 00h
	; limpiamos variable auxiliar
	             clean       auxCadena, SIZEOF auxCadena

	RECORRER:    
	             mov         bl, origen[si]
	; comparmos separador de cadena
	             cmp         bl, '$'
	             je          END
	             cmp         bl, '%'
	; si es separador de cadena comparamos posicion
	             je          COMPARAR
	             mov         auxCadena[di], bl
	             inc         si
	             inc         di
	             jmp         RECORRER

	COMPARAR:    
	; limpiamos el registro para acceder al arreglo de posiciones
	             xor         di, di
	             xor         bx, bx
	; limpiasmo donde almacenaremos la posicion
	             xor         ax, ax
	             mov         ax, cont2
	             mov         bx, 2
	; multiplico ax * 2
	             imul        bx
	; coloco la posicion del arreglo de posiciones
	             mov         di, ax
	; obtengo la posicion del arreglo
	             xor         ax, ax
	             mov         ax, posiciones[di]
	; comparo la posicion en la que voy con la que deberia de ir
	             cmp         ax, cx
	             je          AGREGAR
	; si no es lo posicion continuo a la siguiente
	             jmp         AUMENTAR

	AUMENTAR:    
	; limpio el registro di y la cadena auxiliar
	             xor         di, di
	             clean       auxCadena, SIZEOF auxCadena
	; incremento el contador
	             inc         cx
	; compara que cx no se mas grande que el tamaño del arreglo de posiciones
	             cmp         cx, cont
	; si es mas grande significa que ya estan todos colocados
	             jg          RESTART
	; sino incremento si para saltar el %
	             inc         si
	; continuo a obtener la cadena
	             jmp         RECORRER

	AGREGAR:     
	             pushRecords
	; guardamos el registro
	             saveOnArray auxCadena, destino
	; agregamos suparador a la lista
	             mov         bl, '%'
	             mov         destino[di], bl
	             popRecords
	; incremento al siguiente en contador para la lista de posiciones
	             inc         cont2
	             mov         dx, cont2
	             cmp         dx, cont
	             jg          END
	             jmp         AUMENTAR

	RESTART:     
	             xor         cx, cx
	             xor         si, si
	             jmp         RECORRER

	END:         

endm

;reporte de top10 en consola
reporteTOP macro title, lista, tipo
	           LOCAL          RECORRER, SEPARAR, IMPRIMIR, END, COMPARAR, PUNTAJE, TIME, SIGUIENTE, ENCABEZADO, TITULO1, TITULO2
	; indice del arreglo de la lista ordenada
	           xor            si, si
	; indice que llevara la cadena auxiliar
	           xor            di, di
	; limpiar el contador paara solo imprimir 10
	           xor            cx, cx
	; limpiar cadena auxiliar
	           clean          auxCadena, SIZEOF auxCadena
	           print          linea
	           print          salto
	           print          tab
	           print          tab
	           print          title
	           print          salto
	           print          linea
	           print          salto
	           print          numeral
	           print          tab1
	           print          usuarioT
	           print          tab
	           print          tab
	           print          nivel
	           print          tab1
	           print          tab

	ENCABEZADO:
	           mov            bl, 49
	           cmp            bl, tipo
	           je             TITULO1
	           jmp            TITULO2

	TITULO1:   
	           print          punteoT
	           print          salto
	           print          linea
	           print          salto
	           jmp            RECORRER

	TITULO2:   
	           print          tiempoT
	           print          salto
	           print          linea
	           print          salto
	           jmp            RECORRER

	RECORRER:  
	           mov            bl, lista[si]
	; comparamos fin de arreglo
	           cmp            bl, '$'
	           je             END
	; comparamos separador de registro
	           cmp            bl, '%'
	           je             SEPARAR
	; sino pues guardamos en cadena auxiliar
	           mov            auxCadena[di], bl
	           inc            si
	           inc            di
	           jmp            RECORRER

	SEPARAR:   
	           pushRecords
	; separamos el registro
	           separateRecord auxCadena
	           popRecords
	; incrementamos el numero
	           inc            cx
	           pushRecords
	           mov            ax, cx
	           clean          auxCadena, SIZEOF auxCadena
	; convertimos el numero a string
	           to_string      auxCadena
	           popRecords
	           jmp            IMPRIMIR

	IMPRIMIR:  
	; imprimimos el numero
	           print          auxCadena
	; imprimivos el punto
	           print          punto
	           print          tab1
	; imprimimos el usuario
	           print          user
	; imprimimos espacio en blanco
	           print          tab
	; imprimimos nivel
	           print          tab
	           print          level
	; imprimimos espacio en blanco
	           print          tab1
	           print          tab
	; vemos si imprimimos punteo o tiempo
	           jmp            COMPARAR

	COMPARAR:  
	; si el tipo es 1 significa es punteo
	           mov            bl, 49
	           cmp            bl, tipo
	           je             PUNTAJE
	           jmp            TIME

	PUNTAJE:   
	           print          punteo
	           jmp            SIGUIENTE

	TIME:      
	           print          tiempo
	           print          segundo
	           jmp            SIGUIENTE

	SIGUIENTE: 
	; comparamos si ya imprimimos 10
	           print          salto
	           cmp            cx, 10
	           je             END
	; saltamos el '%'
	           inc            si
	           xor            di, di
	           clean          auxCadena, SIZEOF auxCadena
	           jmp            RECORRER

	END:       

endm

; GRAFICAR
;Activar Modo Video 
ModoVideoOn macro
	            mov ax,13h
	            int 10h
endm
;Desactivar Modo Video 
ModoVideoOff macro
	             mov ax,3h
	             int 10h
endm

; pintar bloque de puntaje
PintarBloque macro posX,posY,sizeX,sizeY,color		;x0,y0,tamX,tamY,color
	             LOCAL       EJEX,EJEY,FIN
	             pushRecords
	             xor         di,di
	             xor         si,si
	             mov         di,posX      	;x
	             mov         si,posY      	;y
	EJEX:        
	             PintarPixel di,si,color
	             inc         di
	             xor         dx,dx
	             mov         dx,posX
	             add         dx,sizeX
	             cmp         di,dx
	             jne         EJEX
	EJEY:        
	             dec         si
	             xor         di,di
	             mov         di,posX
	             xor         dx,dx
	             mov         dx,posY
	             sub         dx,sizeY
	             cmp         si,dx
	             jne         EJEX
	FIN:         
	             popRecords
endm

PintarPixel macro posx,posy,color		;x0,y0,color
	            pushRecords
	            mov         ah,0ch
	            mov         al,color
	            mov         bh,0h
	            mov         dx,posy
	            mov         cx,posx
	            int         10h
	            popRecords
endm
; Activar Modo Video 
ModoVideoOn macro
	            mov ax,13h
	            int 10h
endm
; Desactivar Modo Video 
ModoVideoOff macro
	             mov ax,3h
	             int 10h
endm

PintarLinea macro posX,posY,color,tam,direccion 		;x0,y0,color,largo,direccion(1=horizontal,0=vertical)
	            LOCAL       DIRECCION1,EJEX,EJEY,FIN
    
	            push        di
	            push        si
	            push        bx
	            push        cx
	            xor         di,di
	            xor         si,si
	            mov         di,posX
	            mov         si,posY
	            mov         cx,direccion

	DIRECCION1: 
	            cmp         cx,1
	            je          EJEX
	            cmp         cx,0
	            je          EJEY
	            jmp         FIN

	EJEX:       
	            PintarPixel di,si,color
	            inc         di
	            xor         bx,bx
	            mov         bx,posX
	            add         bx,tam
	            cmp         di,bx
	            je          FIN
	            jmp         EJEX

	EJEY:       
	            PintarPixel di,si,color
	            inc         si
	            xor         bx,bx
	            mov         bx,posY
	            add         bx,tam
	            cmp         si,bx
	            je          FIN
	            jmp         EJEY

	FIN:        
	            pop         di
	            pop         si
	            pop         bx
	            pop         cx
endm

; pintar cuador
pintarCuadro macro
	             PintarLinea 10, 20, blanco, 300, 1
	             PintarLinea 10, 20, blanco, 170, 0
	             PintarLinea 10, 190, blanco, 300, 1
	             PintarLinea 310, 20, blanco, 171, 0
endm

; mover la posicion del cursor
moverCursor macro posX, posY
	            mov ah, 02h
	            mov bh, 00h
	            mov dl, posX
	            mov dh, posY
	            int 10h
endm

; escribir caracter
escribirChar macro caracter, color
	             mov ah, 09h
	             mov al, caracter
	             mov bh, 00h
	             mov bl, color
	             mov cx, 01h
	             int 10h
endm

; escribir cadena en modo video
escribirCadena macro posX, posY, texto
	               LOCAL        RECORRER, SALIR, INCREMENTAR
	               pushRecords
	; indice del arreglo
	               xor          si, si
	               xor          bx, bx
	;xor          dx, dx
	               mov          dl, posX
	               mov          dh, posY
	
	RECORRER:      
	               mov          bl, texto[si]
	; comparamos fin de cadena
	               cmp          bl, '$'
	               je           SALIR
	               moverCursor  dl, dh
	               escribirChar bl, blanco
	               jmp          INCREMENTAR
	
	INCREMENTAR:   
	               inc          dl
	               inc          si
				   
	               jmp          RECORRER

	SALIR:         
	               popRecords
endm

; limpiar pantalla
clearScreen macro
	            mov ah, 06h
	            mov al, 00h
	            mov bh, negro
	            mov dl, 79
	            mov dh, 24
	            mov cx, 00h
	            int 10h
endm

; DELAY
Delay macro number
	      local D1, D2, EndGC
    
	      push  si
	      push  di

	      mov   si, number
	D1:   
	      dec   si
	      jz    EndGC
	      mov   di, number
	D2:   
	      dec   di
	      jnz   D2
	      JMP   d1
	EndGC:
	      pop   di
	      pop   si
endm

; pintar barras
pintarBarras macro lista
	             LOCAL        RECORRER, PINTAR, INCREMENTAR, SALIR
	; indice del arreglo
	             xor          si, si
	; numero obtenido
	             xor          bx, bx
	; cantidad de barras
	             xor          cx, cx
	; posicion x de la barra
	             xor          ax, ax
	             mov          ax, 20
	             xor          di, di
	;anchura
	             xor          dx, dx
	             push         ax
	             anchura
	             pop          ax

	RECORRER:    
	             mov          bx, lista[si]
	             mov          punteoAux, bx
	; calcular altura
	             pushRecords
	             height       punteoAux
	             popRecords
	; calcular color
	             pushRecords
	             selColor     punteoAux
	             popRecords
	             jmp          PINTAR
			
	PINTAR:      
	             pushRecords
	             PintarBloque ax, 170, base, altura, color
	             popRecords
	             pushRecords
	             setPoints    punteoAux, ax
	             popRecords
	             jmp          INCREMENTAR

	INCREMENTAR: 
	; movemos poscion inicial de la barra
	             add          ax, base
	             add          ax, separacion
	; incrementamos el indice del arreglo
	             inc          si
	             inc          si
	; comparamos que sea la cantidad de barras
	             cmp          di, cont
	             jge          SALIR
	; incrementamos barra agregada
	             inc          di
	             jmp          RECORRER
	SALIR:       

endm

; calculamos el color dependiendo 
selColor macro value
	         LOCAL RED, BLUE, WHITE, YELLOW, GREEN, SALIR, DEFAULT

	         mov   bx, value
	         cmp   bx, 21
	         jl    RED
	         cmp   bx, 41
	         jl    BLUE
	         cmp   bx, 61
	         jl    YELLOW
	         cmp   bx, 81
	         jl    GREEN
	         cmp   bx, 99
	         jl    WHITE
	         jmp   DEFAULT

	RED:     
	         mov   color, rojo
	         jmp   SALIR

	BLUE:    
	         mov   color, azul
	         jmp   SALIR

	YELLOW:  
	         mov   color, amarillo
	         jmp   SALIR

	GREEN:   
	         mov   color, verde
	         jmp   SALIR

	WHITE:   
	         mov   color, blanco
	         jmp   SALIR

	DEFAULT: 
	         mov   color, morado
	         jmp   SALIR

	SALIR:   

endm

; calculamos la altura
height macro puntaje
	       LOCAL SALIR, SALIR2
	       xor   ax, ax
	       xor   bx, bx

	       mov   ax, 140
	       mov   bx, puntaje

	; por si la altura es 0 no hago nada
	       cmp   bx, 0
	       je    SALIR

	; 140 px * puntaje / puntaje maximo
	       mul   bx
	       xor   bx, bx
	       mov   bx, max
	       idiv  bx
	       mov   altura, ax
	       jmp   SALIR2
		   
	SALIR: 
	       mov   altura, 1

	SALIR2:
		   
endm

; calcular base
anchura macro
	        mov  bx, cont
	        inc  bx
	        mov  ax, 280
	        idiv bx
	        mov  base, ax
	        sub  base, 10
endm

; colocar punteo debajo de la barra
setPoints macro numero, posX
	          pushRecords
	          clean          auxCadena, SIZEOF auxCadena
	          mov            ax, numero
	          to_string      auxCadena
	          popRecords
	          mov            bx, 10
	          xor            dx, dx
	; muevo pos x a ax
	          mov            ax, posX
			  
	; divido entre 5
	          idiv           bx
	          moverCursor    0, 0
	          escribirCadena al, 48, auxCadena
endm

; ordenamiento con grafica
BubbleSortG macro array, velocidad, forma
	            LOCAL       JUMP3, JUMP2, JUMP1, ASCENDENTE, DESCENDENTE ,PINTAR
	            xor         di, di
	            mov         cont2, 00h
	JUMP3:      
	            mov         si, di
	            inc         si
	            inc         si
	JUMP2:      
	            mov         ax, array[di]                                       	; al
	            mov         dx, array[si]
	            cmp         dx, '$'
	            je          JUMP1
	; comparo si es ascendente o descendente
	            cmp         forma, 50
	            je          DESCENDENTE
	
	ASCENDENTE: 
	            cmp         ax, dx
	            jge         JUMP1
	            mov         array[di], dx
	            mov         array[si], ax
	            jmp         PINTAR

	DESCENDENTE:
	            cmp         ax, dx
	            jle         JUMP1
	            mov         array[di], dx
	            mov         array[si], ax
	            jmp         PINTAR
	PINTAR:     
	            pushRecords
	            graphChange array, velocidad
	            popRecords

	JUMP1:      
	            inc         si
	            inc         si
	            cmp         si, SIZEOF array
	            jnz         JUMP2
	            inc         di
	            inc         di
	            inc         cont2
	            mov         cx, cont2
	            cmp         cx, cont
	            jnz         JUMP3
endm

;graficar el intercambio
graphChange macro lista, velocidad
	            LOCAL           DECIMAS, UNIDAD, SEGUIR
	;limpio pantalla
	            clearScreen
	; escribimos parte de arriba
	            pushRecords
	            escribirCadena  0, 1, burbuja
	            mov             al, speed
	            mov             speedLabel[11], al
	            escribirCadena  12, 1, speedLabel
	            popRecords
	            calcularTiempo
	            mov             ah, 0
	            mov             al, minFinal
	            clean           auxCadena, SIZEOF auxCadena
	            pushRecords
	            to_string       auxCadena
	            popRecords
	            mov             bl, auxCadena[0]
	            mov             timeLabel[9], bl
	            mov             ah, 0
	            mov             al, segFinal
	            clean           auxCadena, SIZEOF auxCadena
	            pushRecords
	            to_string       auxCadena
	            popRecords
	            mov             bl, auxCadena[1]
	            cmp             bl, '$'
	            jne             DECIMAS

	DECIMAS:    
	            mov             timeLabel[12], bl
	            mov             bl, auxCadena[0]
	            mov             timeLabel[11], bl
	            jmp             SEGUIR

	UNIDAD:     
	            mov             bl, auxCadena[0]
	            mov             timeLabel[11], bl
	            jmp             SEGUIR

	SEGUIR:     
	            escribirCadena  26, 1, timeLabel
	; pintar cuadro
	            pintarCuadro
	; pintar barra con cam
	            pintarBarras    lista
	            speedCalculator velocidad
	            Delay           time
endm

MenuOrdenamiento macro lista
	                 LOCAL          ORDENAMIENTO, VELOCIDAD, TIPO, COMPARAR, ORDER1, ORDER2, ORDER3, ORDENAMIENTO, END
	                 xor            ax, ax
	ORDENAMIENTO:    
	; imprimimos el menu de tipo de ordenamiento
	                 print          linea
	                 print          orderType
	                 print          linea
	                 print          opcionOr
	                 getChar
	; comparamos que el caracter ingresado sea valido
	                 cmp            al, 49
	                 jl             ORDENAMIENTO
	                 cmp            al, 51
	                 jg             ORDENAMIENTO
	; guardamos seleccion
	                 mov            orderSel, al
	                 jmp            VELOCIDAD
	VELOCIDAD:       
	; imprimimos seleccion de velocidad
	                 print          linea
	                 print          speedSel
	                 getChar
	; comparamos que la velocidad ingresada sea valida
	                 cmp            al, 48
	                 jl             VELOCIDAD
	                 cmp            al, 57
	                 jg             VELOCIDAD
	; si es correcta la guardamos
	                 mov            speed, al
	                 jmp            TIPO

	TIPO:            
	; imprimimos si deseamos ascendente o descendente
	                 print          linea
	                 print          orderType
	                 print          linea
	                 print          tipoOrden
	                 getChar
	; comparamos que el caracter ingresado sea valido
	                 cmp            al, 49
	                 jl             TIPO
	                 cmp            al, 50
	                 jg             TIPO
	; guardamos seleccion
	                 mov            forma, al
	                 jmp            COMPARAR

	comparar:        
	; ordenamiento burbuja
	                 cmp            orderSel, 49
	                 je             ORDER1
	; ordenamiento quicksort
	                 cmp            orderSel, 49
	                 je             ORDER2
	; ordenamiento shellsort
	                 cmp            orderSel, 49
	                 je             ORDER3

	ORDER1:          
	                 obtenerInicial
	                 ModoVideoOn
	                 BubbleSortG    lista, speed, forma
	                 getChar
	                 ModoVideoOff
	                 jmp            END
	ORDER2:          
	ORDER3:          
	                 print          aunNo
	                 jmp            END

	END:             

endm

speedCalculator macro velocidad
	                LOCAL DEFAULT, SALIR
	                mov   time, 00h
	; comparar si es 0 asi dejo la velocidad como esta
	                cmp   velocidad, 48
	                je    DEFAULT
	; si no es  hago el calculo
	                xor   ax, ax
	                xor   bx, bx
	                xor   dx, dx
	                mov   bl, velocidad
	                mov   ax, 53000
	                idiv  bx
	                mov   time, ax
	                jmp   SALIR

	DEFAULT:        
	                mov   time, 1200
	                jmp   SALIR

	SALIR:          

endm

calcularTiempo macro
	               LOCAL       MINUTO, SEGUNDO,SALIR
	               pushRecords
	               mov         ah, 2ch
	               int         21h
	               mov         minFinal, cl
	               mov         segFinal, dh
	               mov         dl, segInicial
	               cmp         dl, cl
	               jge         MINUTO
	               jmp         SEGUNDO

	MINUTO:        
	               xor         ax, ax
	               xor         bx, bx
	               mov         al,cl
	               sub         minFinal, al
	               add         minFinal, 1
	               mov         bl, segInicial
	               sub         bl, segFinal
	               mov         segFinal, bl
	               jmp         SALIR

	SEGUNDO:       
	               xor         ax, ax
	               xor         bx, bx
	               mov         al,cl
	               sub         minFinal, al
	               mov         bl, segInicial
	               sub         segFinal, bl
	               jmp         SALIR
	              
	SALIR:         
	               popRecords
endm

obtenerInicial macro
	               pushRecords
	               mov         ah, 2ch
	               int         21h
	               mov         minInicial, cl
	               mov         segInicial, dh
	               popRecords
endm


