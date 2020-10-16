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
	          mov         listaUsuarios[di], '%'
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
	           LOCAL RECORRER, VALIDAR, ERRORSIZE, EXISTENCIA , SALIR
	           xor   si, si
	           xor   cx, cx

	RECORRER:  
	           mov   bl, user[si]
	           cmp   bl, '$'
	           je    VALIDAR
	           inc   si
	           jmp   RECORRER

	VALIDAR:   
	           cmp   si, 7
	           jg    ERRORSIZE
	           jmp   EXISTENCIA
	
	EXISTENCIA:
	; SI EXISTE
	;jne

	ERRORSIZE: 
	

endm
; separacion de usuario y contrasena
; la estructura que separamos es usuario:constrasena
separate macro buffer
	         LOCAL U

endm