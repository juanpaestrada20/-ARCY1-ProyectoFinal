print macro cadena
	         LOCAL ETIQUETA
	ETIQUETA:
	         MOV   ah,09h
	         MOV   dx,@data
	         MOV   ds,dx
	         lea   dx, cadena
	         int   21h
endm
getChar macro
	        mov ah,01h
	        int 21h
endm
getText macro buffer
	         LOCAL   CONTINUE, SALIR
	         PUSH    SI
	         PUSH    AX

	         xor     si,si
	CONTINUE:
	         getChar
	         cmp     al,0dh
	         je      SALIR
	         mov     buffer[si],al
	         inc     si
	         jmp     CONTINUE

	SALIR:   
	         mov     al,'$'
	         mov     buffer[si],al

	         POP     AX
	         POP     SI
endm
getRuta macro buffer
	        LOCAL   INICIO,FIN
	        xor     si,si
	INICIO: 
	        getChar
	        cmp     al,0dh
	        je      FIN
	        mov     buffer[si],al
	        inc     si
	        jmp     INICIO
	FIN:    
	        mov     buffer[si],00h
endm
createFile macro buffer, handle
	           mov ah,3ch
	           mov cx,00h
	           lea dx,buffer
	           int 21h
	           mov handle,ax
	           jc  ErrorCrear
endm
writeFile macro numbytes, buffer, handle
	          pushRecords
	          mov         ah, 40h
	          mov         bx,handle
	          mov         cx, numbytes
	          lea         dx,buffer
	          int         21h
	          popRecords
	          jc          ErrorEscribir
endm
openFile macro ruta, handle
	         mov ah,3dh
	         mov al,10b
	         lea dx,ruta
	         int 21h
	         mov handle,ax
	         jc  ErrorAbrir
endm
closeFile macro handle
	          mov ah,3eh
	          mov handle,bx
	          int 21h
endm
readFile macro numbytes,buffer,handle
	         mov ah,3fh
	         mov bx,handle
	         mov cx,numbytes
	         lea dx,buffer
	         int 21h
	         jc  ErrorLeer
endm
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
pushRecords macro
	            push ax
	            push bx
	            push cx
	            push dx
	            push si
	            push di
endm
popRecords macro
	           pop di
	           pop si
	           pop dx
	           pop cx
	           pop bx
	           pop ax
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
	            xor   dx, dx
	            xor   bx, bx
	            xor   cx,cx
	            xor   si,si
	            xor   di,di
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
saveOnArray macro auxCadena, array
	            LOCAL ASIGNACION, FIN, POSICION
	            xor   si, si
	            xor   di, di
				
	POSICION:   
	            mov   bl, array[di]
	            cmp   bl, '$'
	            je    ASIGNACION
	            inc   di
	            jmp   POSICION

	ASIGNACION: 
	            mov   bl, auxCadena[si]
	            cmp   bl, '$'
	            je    FIN
	            mov   array[di], bl
	            inc   di
	            inc   si
	            jmp   ASIGNACION

	FIN:        
endm
lecturaArchivos macro
	                clean      bufferLectura, SIZEOF bufferLectura
	                openFile   rutaUsuarios, handleFichero
	                readFile   SIZEOF bufferLectura, bufferLectura, handleFichero
	                closeFile  handleFichero
	                readUsers  bufferLectura
	                clean      bufferLectura, SIZEOF bufferLectura
	                openFile   rutaPunteos, handleFichero
	                readFile   SIZEOF bufferLectura, bufferLectura, handleFichero
	                closeFile  handleFichero
	                readPoints bufferLectura
					
endm

;Lectura de usuarios
readUsers macro buffer
	          LOCAL       GETUSER, INCREMENT, CONTINUE, END
	          xor         si, si
	          xor         di, di
	          clean       auxCadena, SIZEOF auxCadena

	GETUSER:  
	          mov         bl, buffer[si]
	          cmp         bl, '$'
	          je          END
	          cmp         bl, ';'
	          je          CONTINUE
	          mov         auxCadena[di], bl
	          jmp         INCREMENT

	INCREMENT:
	          inc         si
	          inc         di
	          jmp         GETUSER

	CONTINUE: 
	          pushRecords
	          saveOnArray auxCadena, listaUsuarios
	          mov         bl, '%'
	          mov         listaUsuarios[di], bl
	          popRecords
	          inc         si
	          inc         si
	          inc         si
	          clean       auxCadena, SIZEOF auxCadena
	          xor         di, di
	          jmp         GETUSER

	END:      

endm

;lectura de puntajes
readPoints macro buffer
	           LOCAL       GETRECORD, CONTINUE, INCREMENT, END
	           xor         si, si
	           xor         di, di
	           clean       auxCadena, SIZEOF auxCadena
	GETRECORD: 
	           mov         bl, buffer[si]
	           cmp         bl, '$'
	           je          END
	           cmp         bl, ';'
	           je          CONTINUE
	           mov         auxCadena[di], bl
	           jmp         INCREMENT

	INCREMENT: 
	           inc         si
	           inc         di
	           jmp         GETRECORD

	CONTINUE:  
	           pushRecords
	           saveOnArray auxCadena, listaPunteos
	           mov         bl, '%'
	           mov         listaPunteos[di], '%'
	           popRecords
	           inc         si
	           inc         si
	           inc         si
	           clean       auxCadena, SIZEOF auxCadena
	           xor         di, di
	           jmp         GETRECORD

	END:       
endm
verifyUser macro user
	           LOCAL     RECORRER, VALIDAR, ERRORSIZE, EXISTENCIA , SALIR, ERROR, ADMIN
	           xor       si, si
	           xor       di, di
	           xor       cx, cx
	RECORRER:  
	           mov       bl, user[si]
	           cmp       bl, '$'
	           je        VALIDAR
	           inc       si
	           jmp       RECORRER

	VALIDAR:   
	           cmp       si, 7
	           jg        ERRORSIZE
	           cmp       si, 1
	           jl        ERRORSIZE
	           jmp       EXISTENCIA
	
	EXISTENCIA:
	           userExist user
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
	           xor   si, si
	           xor   di, di
	           xor   bx, bx

	GETLIST:   
	           mov   bl, listaUsuarios[si]
	           cmp   bl, ':'
	           je    COMPARE
	           cmp   bl, '$'
	           je    ACCEPTED
	           mov   auxCadena[di], bl
	           jmp   INCREMENT

	INCREMENT: 
	           inc   si
	           inc   di
	           jmp   GETLIST

	COMPARE:   
	           push  si
	           xor   cx, cx
	           mov   cx, di
	           mov   ax, ds
	           mov   es, ax
	           xor   si, si
	           xor   di, di
	           lea   si, user
	           lea   di, auxCadena
	           repe  cmpsb
	           je    EQUALS
	           pop   si
	           jmp   NEXT

	EQUALS:    
	           pop   si
	           mov   bl, 'Y'
	           jmp   END

	NEXT:      
	           xor   di, di
	           clean auxCadena, SIZEOF auxCadena
	           mov   bl, listaUsuarios[si]
	           cmp   bl, '%'
	           je    INCREMENT2
	           inc   si
	           jmp   NEXT

	INCREMENT2:
	           inc   si
	           jmp   GETLIST

	ACCEPTED:  
	           mov   bl, 'N'
	           jmp   END

	END:       

endm
verifyPass macro pass
	           LOCAL RECORRER, INCORRECT, END, COMPARE, ERROR
	           xor   si, si
	           xor   di, di
	RECORRER:  
	           mov   bl, pass[si]
	           cmp   bl, '$'
	           je    COMPARE
	           cmp   bl, '0'
	           jl    INCORRECT
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
addNewUser macro user, pass
	           pushRecords
	           saveOnArray user, listaUsuarios
	           mov         bl, ':'
	           mov         listaUsuarios[di], bl
	           saveOnArray pass, listaUsuarios
	           mov         bl, '%'
	           mov         listaUsuarios[di], bl
	           popRecords

	           print       listaUsuarios
endm
login macro user, pass
	            LOCAL         SEARCH, CONTRA, ADMIN, ADMINCONTRA,NOUSER, COMPARE, WRONGPASS, ACCESS, ORDER
	            xor           si, si
	            xor           di, di
	            clean         auxCadena, SIZEOF auxCadena
	            clean         punteo, SIZEOF punteo
	            mov           punteoAux, 00h
	            clean         orderedUsersPoints, SIZEOF orderedUsersPoints
	            mov           tiempoAux, 00h
	            clean         orderedUsersTimes, SIZEOF orderedUsersTimes
	SEARCH:     
	            userExist     user
	            xor           di, di
	            clean         auxCadena, SIZEOF auxCadena
	            cmp           bl, 'Y'
	            je            CONTRA
	            jmp           ADMIN

	ADMIN:      
	            xor           si,si
	            xor           di, di
	            xor           cx, cx
	            mov           cx, 8
	            lea           si, adminUser
	            lea           di, user
	            repe          cmpsb
	            je            ADMINCONTRA
	            jmp           NOUSER
	CONTRA:     
	            inc           si
	            mov           bl, listaUsuarios[si]
	            cmp           bl , '%'
	            je            COMPARE
	            mov           auxCadena[di], bl
	            inc           di
	            jmp           CONTRA
	          
	NOUSER:     
	            print         msmError9
	            print         salto
	            jmp           Menu

	ADMINCONTRA:
	            xor           si,si
	            xor           di, di
	            xor           cx, cx
	            mov           cx, 5
	            lea           si, adminPass
	            lea           di, pass
	            repe          cmpsb
	            je            ORDER
	            jmp           WRONGPASS

	ORDER:      
	            getNumbers    listaPunteos
	            fillpositions positionsListPoints
	            transferArray positionsListPoints, positionsListTimes
	            transferArray puntajes, orderedPoints
	            BubbleSort    orderedPoints, positionsListPoints
	            orderRecords  listaPunteos, orderedUsersPoints, positionsListPoints
	            inc           cont
	            transferArray tiempos, orderedTimes
	            BubbleSort    orderedTimes, positionsListTimes
	            orderRecords  listaPunteos, orderedUsersTimes, positionsListTimes
	            mov           ax, orderedPoints[0]
	            mov           maxP, ax
	            mov           ax, orderedTimes[0]
	            mov           maxT, ax
	            jmp           AdminMenu

	COMPARE:    
	            xor           si,si
	            xor           di, di
	            xor           cx, cx
	            mov           cx, 5
	            lea           si, auxCadena
	            lea           di, pass
	            repe          cmpsb
	            je            ACCESS
	            jmp           WRONGPASS

	WRONGPASS:  
	            print         msmError10
	            print         salto
	            jmp           IniciarSesion

	ACCESS:     
	            Juego
	            jmp           Menu
endm
getNumbers macro punteos
	           LOCAL          GETRECORD, NEXT, END, SEPARATE
	           xor            si, si
	           xor            di, di
	           xor            cx, cx
	           clean          auxCadena, SIZEOF auxCadena
	           mov            cont, 00h

	GETRECORD: 
	           mov            bl, punteos[si]
	           cmp            bl, '$'
	           je             END
	           cmp            bl, '%'
	           je             SEPARATE
	           mov            auxCadena[di], bl
	           inc            si
	           inc            di
	           jmp            GETRECORD

	SEPARATE:  
	           pushRecords
	           separateRecord auxCadena
	           to_int         punteo
	           mov            punteoAux, ax
	           to_int         tiempo
	           mov            tiempoAux, ax
	           popRecords
	           mov            ax, cx
	           mov            bx, 2
	           imul           bx
	           xor            di, di
	           mov            di, ax
	           xor            ax, ax
	           mov            ax, punteoAux
	           mov            puntajes[di], ax
	           xor            ax, ax
	           mov            ax, tiempoAux
	           mov            tiempos[di], ax
	           inc            cx
	           jmp            NEXT

	NEXT:      
	           inc            si
	           xor            di, di
	           clean          auxCadena, SIZEOF auxCadena
	           jmp            GETRECORD

	END:       
	           mov            cont, cx

endm 
separateRecord macro registro
	               LOCAL USUARIO, NIVEL, PUNTOS, TIEMPOS, NEXT, END, SIGUIENTE, SIGUIENTE2
	               xor   si, si
	               xor   di, di
	               clean user, SIZEOF user
	               clean level, SIZEOF level
	               clean punteo, SIZEOF punteo
	               clean tiempo, SIZEOF tiempo


	USUARIO:       
	               mov   bl, registro[si]
	               cmp   bl, ','
	               je    SIGUIENTE
	               mov   user[di], bl
	               inc   di
	               inc   si
	               jmp   USUARIO

	SIGUIENTE:     
	               xor   di, di
	               jmp   NIVEL

	NIVEL:         
	               inc   si
	               mov   bl, registro[si]
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
	               inc   si
	               mov   bl, registro[si]
	               cmp   bl, ','
	               je    NEXT
	               mov   punteo[di], bl
	               inc   di
	               jmp   PUNTOS

	NEXT:          
	               xor   di,di
	               jmp   TIEMPOS

	TIEMPOS:       
	               inc   si
	               mov   bl, registro[si]
	               cmp   bl, '$'
	               je    END
	               mov   tiempo[di], bl
	               inc   di
	               jmp   TIEMPOS

	END:           

endm
transferArray macro origin, destiny
	              LOCAL RECORRER, INCREMENT, END
	              xor   si, si
	              xor   ax, ax

	RECORRER:     
	              mov   ax, origin[si]
	              cmp   ax, '$'
	              je    END
	              mov   destiny[si], ax
	              jmp   INCREMENT

	INCREMENT:    
	              inc   si
	              inc   si
	              xor   ax, ax
	              jmp   RECORRER

	END:          


endm
transferArray2 macro origin, destiny
	               LOCAL RECORRER, INCREMENT, END
	               xor   si, si
	               xor   ax, ax

	RECORRER:      
	               mov   al, origin[si]
	               cmp   al, '$'
	               je    END
	               mov   destiny[si], al
	               jmp   INCREMENT

	INCREMENT:     
	               inc   si
	               xor   ax, ax
	               jmp   RECORRER

	END:           


endm
printArray macro array
	           LOCAL     GETNUMBER, INCREMENT, END
	           xor       si, si
	           clean     auxCadena, SIZEOF auxCadena

	GETNUMBER: 
	           mov       ax, array[si]
	           cmp       ax, '$'
	           je        END
	           push      si
	           to_string auxCadena
	           print     auxCadena
	           print     salto
	           pop       si
	           jmp       INCREMENT

	INCREMENT: 
	           inc       si
	           inc       si
	           clean     auxCadena, SIZEOF auxCadena
	           jmp       GETNUMBER

	END:       

endm
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
	           mov   ax, array[di]
	           mov   dx, array[si]
	           cmp   dx, '$'
	           je    JUMP1
	
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
fillpositions macro array
	              LOCAL RECORRER, END
	              xor   si, si
	              xor   ax, ax
	              mov   cont2, 00h

	RECORRER:     
	              mov   array[si], ax
	              inc   si
	              inc   si
	              inc   ax
	              inc   cont2
	              mov   cx, cont
	              cmp   cont2, cx
	              jge   END
	              jmp   RECORRER

	END:          

endm
orderRecords macro origen, destino, posiciones
	             LOCAL       RECORRER, COMPARAR, AUMENTAR, END, RESTART, AGREGAR
	             xor         si, si
	             xor         di, di
	             xor         cx, cx
	             xor         dx, dx
	             mov         cont2, 00h
	             clean       auxCadena, SIZEOF auxCadena

	RECORRER:    
	             mov         bl, origen[si]
	             cmp         bl, '$'
	             je          END
	             cmp         bl, '%'
	             je          COMPARAR
	             mov         auxCadena[di], bl
	             inc         si
	             inc         di
	             jmp         RECORRER

	COMPARAR:    
	             xor         di, di
	             xor         bx, bx
	             xor         ax, ax
	             mov         ax, cont2
	             mov         bx, 2
	             imul        bx
	             mov         di, ax
	             xor         ax, ax
	             mov         ax, posiciones[di]
	             cmp         ax, cx
	             je          AGREGAR
	             jmp         AUMENTAR

	AUMENTAR:    
	             xor         di, di
	             clean       auxCadena, SIZEOF auxCadena
	             inc         cx
	             cmp         cx, cont
	             jg          RESTART
	             inc         si
	             jmp         RECORRER

	AGREGAR:     
	             pushRecords
	             saveOnArray auxCadena, destino
	             mov         bl, '%'
	             mov         destino[di], bl
	             popRecords
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
reporteTOP macro title, lista, tipo
	           LOCAL          RECORRER, SEPARAR, IMPRIMIR, END, COMPARAR, PUNTAJE, TIME, SIGUIENTE, ENCABEZADO, TITULO1, TITULO2, INICIO
	           xor            si, si
	           xor            di, di
	           xor            cx, cx

	INICIO:    
	           writeFile      SIZEOF linea - 1, linea, handleFichero
	           writeFile      SIZEOF encab - 1, encab, handleFichero
	           writeFile      SIZEOF datos - 1, datos, handleFichero
			   
	           clean          auxCadena, SIZEOF auxCadena
	           print          linea
	           writeFile      SIZEOF linea - 1, linea, handleFichero
	           print          salto
	           writeFile      SIZEOF salto - 1, salto, handleFichero
	           print          tab
	           writeFile      SIZEOF tab - 1, tab, handleFichero
	           print          tab
	           writeFile      SIZEOF tab - 1, tab, handleFichero
	           print          title
	           writeFile      SIZEOF title - 1, title, handleFichero
	           print          salto
	           writeFile      SIZEOF salto - 1, salto, handleFichero
	           print          linea
	           writeFile      SIZEOF linea - 1, linea, handleFichero
	           print          salto
	           writeFile      SIZEOF salto - 1, salto, handleFichero
	           print          numeral
	           writeFile      SIZEOF numeral - 1, numeral, handleFichero
	           print          tab1
	           writeFile      SIZEOF tab1 - 1, tab1, handleFichero
	           print          usuarioT
	           writeFile      SIZEOF usuarioT - 1, usuarioT, handleFichero
	           print          tab
	           writeFile      SIZEOF tab - 1, tab, handleFichero
	           print          tab
	           writeFile      SIZEOF tab - 1, tab, handleFichero
	           print          nivel
	           writeFile      SIZEOF nivel - 1, nivel, handleFichero
	           print          tab1
	           writeFile      SIZEOF tab1 - 1, tab1, handleFichero
	           print          tab
	           writeFile      SIZEOF tab - 1, tab, handleFichero

	ENCABEZADO:
	           mov            bl, 49
	           cmp            bl, tipo
	           je             TITULO1
	           jmp            TITULO2

	TITULO1:   
	           print          punteoT
	           writeFile      SIZEOF punteoT - 1, punteoT, handleFichero
	           print          salto
	           writeFile      SIZEOF salto - 1, salto, handleFichero
	           print          linea
	           writeFile      SIZEOF linea - 1, linea, handleFichero
	           print          salto
	           writeFile      SIZEOF salto - 1, salto, handleFichero
	           jmp            RECORRER

	TITULO2:   
	           print          tiempoT
	           writeFile      SIZEOF tiempoT - 1, tiempoT, handleFichero
	           print          salto
	           writeFile      SIZEOF salto - 1, salto, handleFichero
	           print          linea
	           writeFile      SIZEOF linea - 1, linea, handleFichero
	           print          salto
	           writeFile      SIZEOF salto - 1, salto, handleFichero
	           jmp            RECORRER

	RECORRER:  
	           mov            bl, lista[si]
	           cmp            bl, '$'
	           je             END
	           cmp            bl, '%'
	           je             SEPARAR
	           mov            auxCadena[di], bl
	           inc            si
	           inc            di
	           jmp            RECORRER

	SEPARAR:   
	           pushRecords
	           separateRecord auxCadena
	           popRecords
	           inc            cx
	           pushRecords
	           mov            ax, cx
	           clean          auxCadena, SIZEOF auxCadena
	           to_string      auxCadena
	           popRecords
	           jmp            IMPRIMIR

	IMPRIMIR:  
	           print          auxCadena
	           quitarDolar    auxCadena
	           writeFile      di, auxCadena, handleFichero
	           print          punto
	           writeFile      SIZEOF punto - 1, punto, handleFichero
	           print          tab1
	           writeFile      SIZEOF tab1 - 1, tab1, handleFichero
	           print          user
	           quitarDolar    user
	           writeFile      di, user, handleFichero
	           print          tab
	           writeFile      SIZEOF tab - 1, tab, handleFichero
	           print          tab
	           writeFile      SIZEOF tab - 1, tab, handleFichero
	           print          level
	           quitarDolar    level
	           writeFile      di, level, handleFichero
	           print          tab1
	           writeFile      SIZEOF tab - 1, tab, handleFichero
	           print          tab
	           writeFile      SIZEOF tab - 1, tab, handleFichero
	           jmp            COMPARAR

	COMPARAR:  
	           mov            bl, 49
	           cmp            bl, tipo
	           je             PUNTAJE
	           jmp            TIME

	PUNTAJE:   
	           print          punteo
	           quitarDolar    punteo
	           writeFile      di, punteo, handleFichero
	           jmp            SIGUIENTE

	TIME:      
	           print          tiempo
	           quitarDolar    tiempo
	           writeFile      di, tiempo, handleFichero
	           print          segundo
	           writeFile      SIZEOF segundo - 1, segundo, handleFichero
	           jmp            SIGUIENTE

	SIGUIENTE: 
	           print          salto
	           writeFile      SIZEOF salto - 1, salto, handleFichero
	           cmp            cx, 10
	           je             END
	           inc            si
	           xor            di, di
	           clean          auxCadena, SIZEOF auxCadena
	           jmp            RECORRER

	END:       

endm
quitarDolar macro buffer
	            LOCAL RECORRER, SALIR
	            xor   di, di
	RECORRER:   
	            mov   bl, buffer[di]
	            cmp   bl, '$'
	            je    SALIR
	            inc   di
	            jmp   RECORRER

	SALIR:      

endm
ModoVideoOn macro
	            mov ax,13h
	            int 10h
endm
ModoVideoOff macro
	             mov ax,3h
	             int 10h
endm
PintarBloque macro posX,posY,sizeX,sizeY,color
	             LOCAL       EJEX,EJEY,FIN
	             pushRecords
	             xor         di,di
	             xor         si,si
	             mov         di,posX
	             mov         si,posY
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
PintarPixel macro posx,posy,color
	            pushRecords
	            mov         ah,0ch
	            mov         al,color
	            mov         bh,0h
	            mov         dx,posy
	            mov         cx,posx
	            int         10h
	            popRecords
endm
ModoVideoOn macro
	            mov ax,13h
	            int 10h
endm
ModoVideoOff macro
	             mov ax,3h
	             int 10h
endm
PintarLinea macro posX,posY,color,tam,direccion
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
pintarCuadro macro
	             PintarLinea 10, 20, blanco, 300, 1
	             PintarLinea 10, 20, blanco, 170, 0
	             PintarLinea 10, 190, blanco, 300, 1
	             PintarLinea 310, 20, blanco, 171, 0
endm
moverCursor macro posX, posY
	            mov ah, 02h
	            mov bh, 00h
	            mov dl, posX
	            mov dh, posY
	            int 10h
endm
escribirChar macro caracter, color
	             mov ah, 09h
	             mov al, caracter
	             mov bh, 00h
	             mov bl, color
	             mov cx, 01h
	             int 10h
endm
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

selColor macro value
	         LOCAL RED, BLUE, WHITE, YELLOW, GREEN, SALIR, DEFAULT
	         xor   bx, bx
	         mov   bx, value
	         cmp   bx, 20
	         jle   RED
	         cmp   bx, 40
	         jle   BLUE
	         cmp   bx, 60
	         jle   YELLOW
	         cmp   bx, 80
	         jle   GREEN
	         cmp   bx, 99
	         jle   WHITE
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
height macro puntaje
	       LOCAL SALIR, SALIR2
	       xor   ax, ax
	       xor   bx, bx

	       mov   ax, 140
	       mov   bx, puntaje

	       cmp   bx, 0
	       je    SALIR
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
	            cmp         forma, 50
	            je          DESCENDENTE
	
	ASCENDENTE: 
	            cmp         ax, dx
	            jle         JUMP1
	            mov         array[di], dx
	            mov         array[si], ax
	            mov         valAux, ax
	            jmp         PINTAR

	DESCENDENTE:
	            cmp         ax, dx
	            jge         JUMP1
	            mov         array[di], dx
	            mov         array[si], ax
	            mov         valAux, ax
	            jmp         PINTAR
	PINTAR:     
	            pushRecords
	            graphChange array, velocidad, burbuja ,valAux
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
graphChange macro lista, velocidad, name, valor
	            LOCAL           DECIMAS, UNIDAD, SEGUIR
	            clearScreen
	            pushRecords
	            escribirCadena  0, 1, name
	            mov             al, speed
	            mov             speedLabel[11], al
	            escribirCadena  12, 1, speedLabel
	            popRecords
	            calcularTiempo
	            clean           auxCadena, SIZEOF auxCadena
	            pushRecords
	            xor             ax, ax
	            mov             al, minFinal
	            to_string       auxCadena
	            popRecords
	            mov             bl, auxCadena[0]
	            mov             timeLabel[9], bl
	            clean           auxCadena, SIZEOF auxCadena
	            pushRecords
	            mov             ah, 0
	            mov             al, segFinal
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
	            mov             timeLabel[11], '0'
	            mov             bl, auxCadena[0]
	            mov             timeLabel[12], bl
	            jmp             SEGUIR

	SEGUIR:     
	            escribirCadena  26, 1, timeLabel
	            pintarCuadro
	            pintarBarras    lista
	            speedCalculator velocidad
	            setHz           valor, time
endm


MenuOrdenamiento macro lista
	                 LOCAL          ORDENAMIENTO, VELOCIDAD, TIPO, COMPARAR, ORDER1, ORDER2, ORDER3, ORDENAMIENTO, END
	                 xor            ax, ax
	ORDENAMIENTO:    
	                 print          linea
	                 print          orderType
	                 print          linea
	                 print          opcionOr
	                 getChar
	                 cmp            al, 49
	                 jl             ORDENAMIENTO
	                 cmp            al, 51
	                 jg             ORDENAMIENTO
	                 mov            orderSel, al
	                 jmp            VELOCIDAD
	VELOCIDAD:       
	                 print          linea
	                 print          speedSel
	                 getChar
	                 cmp            al, 48
	                 jl             VELOCIDAD
	                 cmp            al, 57
	                 jg             VELOCIDAD
	                 mov            speed, al
	                 jmp            TIPO

	TIPO:            
	                 print          linea
	                 print          orderType
	                 print          linea
	                 print          tipoOrden
	                 getChar
	                 cmp            al, 49
	                 jl             TIPO
	                 cmp            al, 50
	                 jg             TIPO
	                 mov            forma, al
	                 jmp            COMPARAR

	comparar:        
	                 cmp            orderSel, 49
	                 je             ORDER1
	                 cmp            orderSel, 50
	                 je             ORDER2
	                 cmp            orderSel, 51
	                 je             ORDER3

	ORDER1:          
	                 obtenerInicial
	                 ModoVideoOn
	                 BubbleSortG    lista, speed, forma
	                 getChar
	                 ModoVideoOff
	                 jmp            END

	ORDER2:          
	                 obtenerInicial
	                 clean2         arrQuick, SIZEOF arrQuick
	                 transferArray  lista, arrQuick
	                 ModoVideoOn
	                 mov            cx,0
	                 mov            bx,cont
	                 call           quickSort
	                 getChar
	                 ModoVideoOff
	                 jmp            END
	ORDER3:          
	                 obtenerInicial
	                 pushRecords
	                 mov            ax, cont
	                 add            ax, 1
	                 mov            bx, 2
	                 mul            bx
	                 mov            tam, ax
	                 print          salto
	                 print          linea
	                 print          salto
	                 popRecords
	                 ModoVideoOn
	                 ShellSort      lista, speed, forma
	                 getChar
	                 ModoVideoOff
	                 jmp            END


	END:             

endm


speedCalculator macro velocidad
	                LOCAL DEFAULT, SALIR
	                mov   time, 00h
	                cmp   velocidad, 48
	                je    DEFAULT
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
	               LOCAL       MINUTO, SEGUNDO,SALIR, AGREGAR
	               pushRecords
	               mov         ah, 2ch
	               int         21h
	               mov         segFinal, dh
	               mov         dl, segInicial
	               cmp         dl, dh
	               jg          MINUTO
	               jmp         SEGUNDO

	MINUTO:        
	               mov         bandera, 1
	               add         segFinal, 60


	SEGUNDO:       
	               xor         bx, bx
	               mov         bl, segInicial
	               sub         segFinal, bl
	               cmp         bandera, 1
	               je          AGREGAR
	               jmp         SALIR

	AGREGAR:       
	               add         minFinal, 1
	               mov         bandera, 0
	              
	SALIR:         
	               popRecords
endm

obtenerInicial macro
	               pushRecords
	               mov         ah, 2ch
	               int         21h
	               mov         minInicial, 0
	               mov         segInicial, dh
	               mov         bandera, 0
	               popRecords
endm

ShellSort macro array, velocidad, forma
	             LOCAL       INICIO, COMPARACION1, COMPARACION2, COMPARACION3, TEMPORAL, COMPARACION3, SWAP, SIG1, SIG2, SIG3, FIN, ASCENDENTE, DESCENDENTE
	             xor         ax, ax
	             xor         bx, bx
	             xor         cx, cx
	             xor         dx, dx
	             xor         di, di
	             xor         si, si

	INICIO:      
	             mov         ax, cont
	             add         ax, 1
	             mov         interval, ax
	             mov         i, ax
	             mov         bx, 2
	             div         bx
	             mov         ah, 0
	             mov         auxTam, ax

	COMPARACION1:
	             mov         ax, interval
	             mov         i, ax
	             cmp         interval, 0
	             jg          COMPARACION2
	             jmp         FIN

	COMPARACION2:
	             xor         ax, ax
	             mov         ax, tam
	             cmp         i, ax
	             jge         SIG1

	TEMPORAL:    
	             xor         si, si
	             xor         dx, dx
	             xor         ax, ax
	             mov         si, i
	             mov         dx, array[si]
	             mov         temp, dx
	             mov         j, 0
	             mov         ax, i
	             mov         j, ax
		

	COMPARACION3:
	             mov         ax, interval
	             cmp         j, ax
	             jl          SIG2
	             mov         ax, j
	             mov         bx, interval
	             sub         ax, bx
	             mov         k, ax
	             xor         di, di
	             mov         di, ax
	             mov         bx, array[di]
	             cmp         forma, 50
	             je          DESCENDENTE

	ASCENDENTE:  
	             cmp         bx, temp
	             jg          SWAP
	             jmp         SIG2

	DESCENDENTE: 
	             cmp         bx, temp
	             jl          SWAP
	             jmp         SIG2


	SWAP:        
	             mov         si, j
	             mov         di, k
	             mov         ax, di
	             mov         bx, array[di]
	             mov         array[si], bx
	             mov         valAux, bx
	             pushRecords
	             graphChange array, velocidad, shell, valAux
	             popRecords
				 
	SIG3:        
	             mov         bx, interval
	             mov         ax, j
	             sub         ax, bx
	             mov         j, ax
	             jmp         COMPARACION3
		
	SIG2:        
	             mov         si, j
	             mov         ax, temp
	             mov         array[si], ax
	             mov         valAux, ax
	             pushRecords
	             graphChange array, velocidad, shell, valAux
	             popRecords
	             mov         temp, 0
	             add         i, 2
	             jmp         COMPARACION2

	SIG1:        
	             mov         ax, auxTam
	             mov         bx, 2
	             div         bl
	             mov         dl, ah
	             mov         ah,0
	             mov         auxTam, ax
	             mul         bx
	             mov         interval, ax
	             jmp         COMPARACION1

	FIN:         
endm

partition macro arreglo,begin,fini
	            LOCAL       INICIO,FIN,INIFOR,FOR,FUERAFOR,FINFOR,DENTROFOR,DENTROIF,RETORNAR, ASCENDENTE, DESCENDENTE
	            PUSH        si
	            PUSH        cx
	            PUSH        di
	            PUSH        ax
	            PUSH        bx
	            xor         si,si
	            xor         cx,cx
	            xor         ax,ax
	            xor         di,di
	            xor         bx,bx
	            xor         dx,dx
     
	;graficar

	INICIO:     
	; PIVOT CX, I di, J si
	            xor         si,si
	            mov         si,fini[0]
	            mov         ax,si
	            xor         si,si
	            mov         si,2
	            imul        si
	            xor         si,si
	            mov         si,ax
	            xor         ax,ax
	            mov         cx,arreglo[si]                                                                            	; se setea pivote en cx
	            xor         si,si
	  
	            mov         si,begin[0]
	            dec         si
	            mov         di,si                                                                                     	; se setea el i en di
	            xor         si,si
	            jmp         INIFOR
      

	INIFOR:     
	            xor         si,si
	            mov         si,begin[0]                                                                               	; seteamos j a si
	            jmp         FOR

	FOR:        
	            cmp         si,fini[0]
	            jl          DENTROFOR
	            jmp         FUERAFOR


	DENTROFOR:  
	;IF:
	            push        si
	            xor         ax,ax
	            mov         ax,si
	            xor         si,si
	            mov         si,2
	            imul        si
	            xor         si,si
	            mov         si,ax
	            xor         ax,ax
	            cmp         forma, 50
	            je          DESCENDENTE

	ASCENDENTE: 
	            cmp         arreglo[si],cx
	            jle         DENTROIF
	            pop         si
	            jmp         FINFOR

	DESCENDENTE:
	            cmp         arreglo[si],cx
	            jGe         DENTROIF
	            pop         si
	            jmp         FINFOR

	DENTROIF:   
	            pop         si
	            xor         dx,dx
	            inc         di
	            xor         bx,bx
	            xor         dx,dx
	            push        di
	            xor         ax,ax
	            mov         ax,di
	            xor         di,di
	            mov         di,2
	            imul        di
	            xor         di,di
	            mov         di,ax
	            xor         ax,ax
	            mov         bx,arreglo[di]                                                                            	; guarda el auxiliar
		 
		 
	            push        si
	            xor         ax,ax
	            mov         ax,si
	            xor         si,si
	            mov         si,2
	            imul        si
	            xor         si,si
	            mov         si,ax
	            xor         ax,ax
        
	            mov         dx,arreglo[si]
	            mov         arreglo[di],dx
	            mov         arreglo[si],bx
	            mov         valAux, bx
	            pushRecords
	            graphChange arreglo, speed, quick, valAux
	            popRecords

	            xor         dx,dx
	            xor         bx,bx
	            xor         si,si
	            pop         si
	            xor         di,di
	            pop         di
	            jmp         FINFOR

	FINFOR:     
	            inc         si
	            jmp         FOR

	  	 
	FUERAFOR:   
	            push        di
	            xor         ax,ax
	            inc         di
	            mov         ax,di
	            xor         di,di
	            mov         di,2
	            imul        di
	            xor         di,di
	            mov         di,ax
	            xor         ax,ax
	            mov         bx,arreglo[di]                                                                            	; guarda el auxiliar
		 
		 
	            push        si
	            xor         ax,ax
	            xor         si,si
	            mov         si,fini[0]
	            mov         ax,si
	            xor         si,si
	            mov         si,2
	            imul        si
	            xor         si,si
	            mov         si,ax
	            xor         ax,ax
        
	            mov         dx,arreglo[si]
	            mov         arreglo[di],dx
	            mov         arreglo[si],bx
	            mov         valAux, bx
	            pushRecords
	            graphChange arreglo, speed, quick, valAux
	            popRecords
	            xor         dx,dx
	            xor         bx,bx
	            xor         si,si
	            pop         si
	            xor         di,di
	            pop         di
	            
	            jmp         RETORNAR

	RETORNAR:   
	            inc         di
	            mov         dx,di
	            jmp         FIN

	FIN:        
	            xor         si,si
	            xor         cx,cx
	            xor         ax,ax
	            xor         di,di
	            xor         bx,bx
	            POP         bx
	            POP         ax
	            POP         di
	            POP         cx
	            POP         si
endm
clean2 macro array, numBytes
	           LOCAL       RepeatLoop
	           pushRecords
	           xor         si, si
	           xor         cx, cx
	           mov         cx, numBytes
	RepeatLoop:
	           mov         array[si], '$'
	           inc         si
	           inc         si
	           Loop        RepeatLoop
	           popRecords
endm
setHz macro valor, duracion
	       LOCAL  INICIO, FIN, RED, BLUE, YELLOW, GREEN, WHITE, OTHER
	INICIO:
	       mov    ax, valor
	       cmp    ax, 20
	       jle    RED
	       cmp    ax, 40
	       jle    BLUE
	       cmp    ax, 60
	       jle    YELLOW
	       cmp    ax, 80
	       jle    GREEN
	       cmp    ax, 99
	       jle    WHITE
	       jmp    OTHER

	RED:   
	       sonido 100, duracion
	       jmp    FIN
	BLUE:  
	       sonido 300, duracion
	       jmp    FIN
	YELLOW:
	       sonido 500, duracion
	       jmp    FIN
	GREEN: 
	       sonido 700, duracion
	       jmp    FIN
	WHITE: 
	       sonido 900, duracion
	       jmp    FIN

	OTHER: 
	       sonido 1100, duracion
	       jmp    FIN
			 

	FIN:   
endm
sonido macro hz,delaym
	       LOCAL inicio,fin

	inicio:

	       push  ax
	       push  cx

	       xor   ax, ax
	       xor   cx, cx

	       mov   al, 86h
	       out   43h, al
	       mov   ax, (1193180 / hz)
	       out   42h, al
	       mov   al, ah
	       out   42h, al
	       in    al, 61h
	       or    al, 00000011b
	       out   61h, al
    
	       Delay delaym

	       in    al, 61h
	       and   al, 11111100b
	       out   61h, al
	fin:   
	       pop   cx
	       pop   ax

endm
transferCadena macro fuente, destino
	               LOCAL RECORRER, FIN
	               xor   si,si
	RECORRER:      
	               mov   bl, fuente[si]
	               cmp   bl, '$'
	               je    FIN
	               mov   destino[si], bl
	               inc   si
	               jmp   RECORRER

	FIN:           
endm

Juego macro
	        LOCAL           DECIMAS, UNIDAD, SEGUIR
	        ModoVideoOn
	        clean           auxCadena, SIZEOF auxCadena
	        escribirCadena  1, 1, usuario
	        mov             bl, nivelActual
	        mov             ene[5], bl
	        escribirCadena  10, 1, ene
	        pushRecords
	        mov             ax, punteoActual
	        to_string       auxCadena
	        popRecords
	        escribirCadena  20, 1, auxCadena
	        pintarCuadro
	        obtenerInicial
	        clean           auxCadena, SIZEOF auxCadena
	        pushRecords
	        xor             ax, ax
	        mov             al, minFinal
	        to_string       auxCadena
	        popRecords
	        mov             bl, auxCadena[0]
	        mov             timeLabel[9], bl
	        clean           auxCadena, SIZEOF auxCadena
	        pushRecords
	        mov             ah, 0
	        mov             al, segFinal
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
	        mov             timeLabel[11], '0'
	        mov             bl, auxCadena[0]
	        mov             timeLabel[12], bl
	        jmp             SEGUIR
	SEGUIR: 
	        escribirCadena  26, 1, timeLabel
	        transferArray2  level11, levelJugar
	        mov             grafX, 19
	        mov             grafY,40
	        pintarCuadritos levelJugar
	        mov             posBarra, 125
	        pintarBloque    posBarra, 180, 70, 7, blanco
	        mov             ballX, 150
	        mov             ballY, 110
	        mov             dirX, 0
	        mov             dirY, 1
	        mov             dir, 7
	        mov             juegoPerdido, 0
	        mov             punteoActual, 0
	        mov             tiempoActual, 0
	        mov             bloquesQuebrados, 0
	        mov             minFinal, 0
	        mov             segFinal, 0
	        pushRecords
	        mov             ax, punteoActual
	        to_string       auxCadena
	        popRecords
	        escribirCadena  20, 1, auxCadena
	        pintarBloque    ballX, ballY, 3, 3, blanco
	        LoopJuego
	        getChar
	        ModoVideoOff
	        print           listaPunteos
	        getChar
endm

colocarTiempo macro
	              LOCAL          DECIMAS, UNIDAD, SEGUIR
	              calcularTiempo
	              clean          auxCadena, SIZEOF auxCadena
	              pushRecords
	              xor            ax, ax
	              mov            al, minFinal
	              to_string      auxCadena
	              popRecords
	              xor            bx, bx
	              mov            bl, auxCadena[0]
	              mov            timeLabel[9], bl
	              clean          auxCadena, SIZEOF auxCadena
	              pushRecords
	              mov            ah, 0
	              mov            al, segFinal
	              to_string      auxCadena
	              popRecords
	              mov            bl, auxCadena[1]
	              cmp            bl, '$'
	              jne            DECIMAS

	DECIMAS:      
	              mov            timeLabel[12], bl
	              mov            bl, auxCadena[0]
	              mov            timeLabel[11], bl
	              jmp            SEGUIR

	UNIDAD:       
	              mov            timeLabel[11], '0'
	              mov            bl, auxCadena[0]
	              mov            timeLabel[12], bl
	              mov            timeLabel[13], '$'
				
	SEGUIR:       
endm
pintarCuadritos macro array
	                LOCAL        RECORRER, FIN, BLUE, ORANGE, GREEN, INCREMENT, MIDDLE, NEXTX, NEXTY, EMPTY
	                xor          si, si
	                xor          di, di
	                xor          cx, cx

	RECORRER:       
	                mov          bl, array[si]
	                cmp          bl, '$'
	                je           FIN
	                cmp          bl, 11b
	                je           BLUE
	                cmp          bl, 10b
	                je           ORANGE
	                cmp          bl, 01b
	                je           GREEN
	                jmp          EMPTY

	EMPTY:          
	                PintarBloque grafX, grafY, 69, 7, negro
	                jmp          INCREMENT

	BLUE:           
	                PintarBloque grafX, grafY, 69, 7, azul
	                jmp          INCREMENT

	ORANGE:         
	                PintarBloque grafX, grafY, 69, 7, naranja
	                jmp          INCREMENT

	GREEN:          
	                PintarBloque grafX, grafY, 69, 7, verde
	                jmp          INCREMENT

	INCREMENT:      
	                inc          si
	                inc          cx
	                cmp          cx, 2
	                je           MIDDLE
	                cmp          cx, 4
	                je           NEXTY
	                jmp          NEXTX

	MIDDLE:         
	                add          grafX, 2
	                jmp          NEXTX
	
	NEXTX:          
	                add          grafX, 70
	                jmp          RECORRER

	NEXTY:          
	                xor          cx, cx
	                mov          grafX, 19
	                add          grafY, 8
	                jmp          RECORRER

	FIN:            
endm

LoopJuego macro
	             LOCAL               RECORRER, DOWNLEFT, DOWNRIGHT, UPLEFT, UPRIGHT, DERECHA, IZQUIERDA, ARRIBA, ABAJO, DIRECCIONAR, FIN, DIRECCIONAR2, PELOTA, BARRA1, BARRA2, PAUSA, NIVELSIG
	             xor                 bx, bx
	             xor                 ax, ax

	RECORRER:    
	             colocarTiempo
	             escribirCadena      26, 1, timeLabel
	             pintarCuadro
	             cmp                 siguienteNivel, 1
	             je                  NIVELSIG
	             pintarBloque        posBarra, 180, 70, 7, blanco
	             pintarBloque        ballX, ballY, 3, 3, blanco
	             Delay               velocity
	             xor                 ax, ax

	             mov                 ah, 01h
	             int                 16h
	             jz                  PELOTA

	             mov                 ah, 00h
	             int                 16h
				 
	             cmp                 al, 61h
	             je                  BARRA1
	             cmp                 al, 41h
	             je                  BARRA1
	             cmp                 al, 44h
	             je                  BARRA2
	             cmp                 al, 64h
	             je                  BARRA2

	             cmp                 al, 27
	             je                  PAUSA
				
	             jmp                 PELOTA

	PAUSA:       
	             getChar
	             cmp                 al, 20h
	             je                  FIN
	             cmp                 al, 27
	             jne                 PAUSA
	
	BARRA1:      
	             cmp                 posBarra, 11
	             jle                 PELOTA
	             sub                 posBarra,5
	             mov                 cx, posBarra
	             add                 cx, 75
	             pintarBloque        cx , 180, 5, 7, negro
	             xor                 ax, ax
	             jmp                 PELOTA

	BARRA2:      
	             cmp                 posBarra, 240
	             jge                 PELOTA
	             add                 posBarra, 5
	             mov                 cx, posBarra
	             sub                 cx, 5
	             pintarBloque        cx , 180, 5, 7, negro
	             xor                 ax, ax
	             jmp                 PELOTA

	PELOTA:      
	             mov                 bx, dir
	             cmp                 bx, 9
	             je                  DOWNRIGHT
	             cmp                 bx, 7
	             je                  DOWNLEFT
	             cmp                 bx, 3
	             je                  UPLEFT
	             cmp                 bx, 5
	             je                  UPRIGHT

	             jmp                 RECORRER

	DOWNLEFT:    
	             pintarBloque        ballX, ballY, 3, 3, negro
	             sub                 ballX, 1
	             add                 ballY, 1
	             pintarBloque        ballX, ballY, 3, 3, blanco
	             jmp                 DIRECCIONAR

	DOWNRIGHT:   
	             pintarBloque        ballX, ballY, 3, 3, negro
	             add                 ballX, 1
	             add                 ballY, 1
	             pintarBloque        ballX, ballY, 3, 3, blanco
	             jmp                 DIRECCIONAR

	UPLEFT:      
	             pintarBloque        ballX, ballY, 3, 3, negro
	             sub                 ballX, 1
	             sub                 ballY, 1
	             pintarBloque        ballX, ballY, 3, 3, blanco
	             jmp                 DIRECCIONAR

	UPRIGHT:     
	             pintarBloque        ballX, ballY, 3, 3, negro
	             add                 ballX, 1
	             sub                 ballY, 1
	             pintarBloque        ballX, ballY, 3, 3, blanco
	             jmp                 DIRECCIONAR

	DIRECCIONAR: 
	             verificarDireccionX dirX
	             mov                 dir, 0
	             cmp                 dirX, 1
	             je                  DERECHA
	             jmp                 IZQUIERDA
	
	DERECHA:     
	             mov                 dir, 4
	             jmp                 DIRECCIONAR2
	           

	IZQUIERDA:   
	             mov                 dir, 2
	             jmp                 DIRECCIONAR2
	            
	DIRECCIONAR2:
	             verificarDireccionY dirY
	             cmp                 juegoPerdido, 1
	             je                  FIN
	             cmp                 dirY, 0
	             je                  ARRIBA
	             jmp                 ABAJO

	ARRIBA:      
	             add                 dir, 1
	             jmp                 RECORRER
	            
	ABAJO:       
	             add                 dir, 5
	             jmp                 RECORRER
	            
	NIVELSIG:    
	             cmp                 nivelActual, 52
	             je                  fin
	             aumentarNivel
	             jmp                 RECORRER
	FIN:         
	             cmp                 siguienteNivel, 1
	             je                  NIVELSIG
	             guardarPuntaje      usuario, nivelActual, punteoActual


endm

aumentarNivel macro
	              LOCAL           FIN, TERCERO, SIGUIENTE
	              clearScreen
	              mov             siguienteNivel, 0
	              sub             velocity, 50
	              add             nivelActual, 1
	              mov             bl, nivelActual
	              mov             ene[5], bl
	              escribirCadena  10, 1, ene
	              clean           levelJugar, SIZEOF levelJugar
	              transferArray2  level11, levelJugar
	              saveOnArray     level11, levelJugar
	              cmp             nivelActual, 51
	              je              TERCERO
	              jmp             SIGUIENTE
	TERCERO:      
	              saveOnArray     level11, levelJugar
	SIGUIENTE:    
	              clean           auxCadena, SIZEOF auxCadena
	              escribirCadena  1, 1, usuario
	              pushRecords
	              mov             ax, punteoActual
	              to_string       auxCadena
	              popRecords
	              escribirCadena  20, 1, auxCadena
	              mov             grafX, 19
	              mov             grafY,40
	              pintarCuadritos levelJugar
	              mov             ballX, 150
	              mov             ballY, 110
	              mov             dirX, 0
	              mov             dirY, 1
	              mov             dir, 7
	              mov             bloquesQuebrados,0
	              pintarCuadro
	              getChar
endm
guardarPuntaje macro user, nivel, punteo
	               saveOnArray usuario, listaPunteos
	               mov         listaPunteos[di], ','
	               clean       auxCadena, SIZEOF auxCadena
	               mov         al, nivel
	               mov         auxCadena[0], al
	               saveOnArray auxCadena, listaPunteos
	               mov         listaPunteos[di], ','
	               pushRecords
	               clean       auxCadena, SIZEOF auxCadena
	               mov         ax, punteo
	               to_string   auxCadena
	               popRecords
	               saveOnArray auxCadena, listaPunteos
	               mov         listaPunteos[di], ','
	               pushRecords
	               clean       auxCadena, SIZEOF auxCadena
	               xor         ax, ax
	               xor         bx, bx
	               mov         al, minFinal
	               mov         bx, 60
	               mul         bx
	               mov         bh, 0
	               mov         bl, segFinal
	               add         ax, bx
	               to_string   auxCadena
	               popRecords
	               saveOnArray auxCadena, listaPunteos
	               mov         listaPunteos[di], '%'
	               

endm

verificarDireccionX macro direccion
	                    LOCAL      DERECHA, CAMBIAR, CAMBIAR2, IZQUIERDA, FIN
	                    cmp        direccion, 0
	                    je         IZQUIERDA
	                    jmp        DERECHA

	IZQUIERDA:          
	                    mov        cx, ballX
	                    sub        cx, 1
	                    getPixel   cx, ballY
	                    cmp        detectado, negro
	                    jne        CAMBIAR
	                    cmp        ballX, 10
	                    jg         FIN
	
	CAMBIAR:            
	                    cmp        detectado, blanco
	                    je         fin
	                    breakBlock cx, ballY
	                    mov        direccion, 1
	                    mov        dirX, 1
	                    jmp        FIN

	DERECHA:            
	                    mov        cx, ballX
	                    add        cx, 3
	                    getPixel   cx, ballY
	                    cmp        detectado, negro
	                    jne        CAMBIAR2
	                    cmp        ballX, 307
	                    jl         FIN

	CAMBIAR2:           
	                    cmp        detectado, blanco
	                    je         fin
	                    breakBlock cx, ballY
	                    mov        direccion, 0
	                    mov        dirX, 0
	                    jmp        FIN
	
	FIN:                
endm
verificarDireccionY macro direccion
	                    LOCAL      ARRIBA, CAMBIAR, ABAJO, CAMBIAR2, FIN, PERDIO
	                    cmp        direccion, 1
	                    je         ABAJO
	                    jmp        ARRIBA

	ABAJO:              
	                    mov        dx, ballY
	                    add        dx, 1
	                    getPixel   ballX, dx
	                    cmp        detectado, negro
	                    jne        CAMBIAR
	                    cmp        ballY, 180
	                    jl         FIN
	                    jge        PERDIO

	CAMBIAR:            
	                    breakBlock ballX, dx
	                    mov        direccion, 0
	                    mov        dirY, 0
	                    jmp        FIN

	ARRIBA:             
	                    mov        dx, ballY
	                    sub        dx, 3
	                    getPixel   ballX, dx
	                    cmp        detectado, negro
	                    jne        CAMBIAR2
	                    cmp        ballY, 22
	                    jg         FIN
	
	CAMBIAR2:           
	                    cmp        detectado, blanco
	                    je         fin
	                    breakBlock ballX, dx
	                    mov        direccion, 1
	                    mov        dirY, 1
	                    jmp        FIN

	PERDIO:             
	                    mov        juegoPerdido, 1
	
	FIN:                
endm

getPixel macro x, y
	         pushRecords
	         mov         ah, 0dh
	         mov         bh, 00h
	         mov         cx, x
	         mov         dx, y
	         int         10h
	         mov         detectado, al
	         popRecords
endm

printColor macro
	           LOCAL       GREEN, BLACK, WHITE, ORANGE, BLUE, fin
	           cmp         al, negro
	           je          BLACK
	           cmp         al, verde
	           je          GREEN
	           cmp         al, naranja
	           je          orange
	           pushRecords
	BLACK:     
	           print       ene
	           getChar
	           jmp         fin
	ORANGE:    
	           print       segundo
	           getChar
	           jmp         fin
	GREEN:     
	           print       usuarioT
	           getChar
	           jmp         fin
	           popRecords
	fin:       
endm

breakBlock macro posX, posY
	           LOCAL           FIN, LINE, COLUMN, DESTROY, L1COMP, L2COMP, L3COMP
	           pushRecords
	           cmp             detectado, blanco
	           je              FIN
	           xor             si, si
	           xor             di, di

	LINE:      
	           cmp             posY, 32
	           jle             FIN
	           cmp             posY, 40
	           jle             COLUMN
	           inc             si
	           cmp             posY, 48
	           jle             COLUMN
	           inc             si
	           cmp             posY, 56
	           jle             COLUMN
	           cmp             nivelActual, 49
	           je              COLUMN
	           inc             si
	           cmp             posY, 64
	           jle             COLUMN
	           inc             si
	           cmp             posY, 72
	           jle             COLUMN
	           inc             si
	           cmp             posY, 80
	           jle             COLUMN
	           cmp             nivelActual, 50
	           je              COLUMN
	           inc             si
	           cmp             posY, 88
	           jle             COLUMN
	           inc             si
	           cmp             posY, 96
	           jle             COLUMN
	           inc             si
	           cmp             posY, 104
	           jle             COLUMN
	           jg              FIN

	COLUMN:    
	           cmp             posX, 18
	           jle             FIN
	           cmp             posX, 88
	           jle             DESTROY
	           inc             di
	           cmp             posX, 158
	           jle             DESTROY
	           inc             di
	           cmp             posX, 230
	           jle             DESTROY
	           inc             di
	           cmp             posX, 300
	           jle             DESTROY
	           jg              FIN

	DESTROY:   
	           mov             ax, si
	           mov             bx, 4
	           mul             bx
	           add             ax, di
	           
	           mov             si, ax
	           mov             levelJugar[si], 00b
	           mov             grafX, 19
	           mov             grafY,40
	           pintarCuadritos levelJugar
	           add             punteoActual, 1
	           add             bloquesQuebrados, 1
	           pushRecords
	           mov             ax, punteoActual
	           to_string       auxCadena
	           popRecords
	           escribirCadena  20, 1, auxCadena
	           cmp             nivelActual, 49
	           je              L1COMP
	           cmp             nivelActual, 50
	           je              L2COMP
	           jmp             L3COMP

	L1COMP:    
	           cmp             bloquesQuebrados, 12
	           jl              fin
	           mov             siguienteNivel, 1
	           jmp             fin
	L2COMP:    
	           cmp             bloquesQuebrados, 24
	           jl              fin
	           mov             siguienteNivel, 1
	           jmp             fin
	L3COMP:    
	           cmp             bloquesQuebrados, 36
	           jl              fin
	           mov             siguienteNivel, 1
	           jmp             fin


	FIN:       
	           popRecords
endm