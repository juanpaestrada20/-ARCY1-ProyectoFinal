;===============SECCION DE MACROS ===========================
include macros.asm
;================= DECLARACION TIPO DE EJECUTABLE ============
.model huge, C
.stack 100h 
.data
	;================ INICIO DE SESION ========================
	linea               db  '----------------------------------------------------------------------------', '$'
	encab               db  0ah,0dh, 'UNIVERSIDAD DE SAN CARLOS DE GUATEMALA', 0ah,0dh,'FACULTAD DE INGENIERIA',0ah,0dh,'CIENCIAS Y SISTEMAS',0ah,0dh,'ARQUITECTURA DE COMPUTADORES 1' ,
0ah,0dh,'SECCION A',0ah,0dh,'Proyecto 2','$'
	datos               db  0ah,0dh, 09h, 09h, 'JUAN PABLO ESTRADA ALEMAN', 0ah,0dh, 09h, 09h, 09h, '201800709',0ah,0dh,'$'
	inicioRegisto       db  0ah,0dh, '1) INGRESAR',0ah,0dh,'2) REGISTRARSE',0ah,0dh,'3) SALIR',0ah,0dh,'$'
	eligaop             db  0ah, 0dh, 'Elija una opcion: ', 0ah, 0dh, '$'
	salto               db  0ah, 0dh , '$'
	tab                 db  09h, 09h , '$'
	tab1                db  09h , '$'
	
	;================ USUARIOS ========================
	newUser             db  0ah, 0dh, 'Ingrese el usuario: ', '$'
	newPass             db  'Ingrese el password: ', '$'
	usuario             db  15 dup('$')                                                                                                                                                 	;
	password            db  10 dup('$')                                                                                                                                                 	;
	adminUser           db  'adminAI','$'
	adminPass           db  '4321', '$'
	listaUsuarios       db  300 dup('$')
	; usuarios con puntos desordenados
	listaPunteos        db  1000 dup('$')
	auxCadena           db  100 dup('$')
	aux                 db  100 dup('$')

	arrQuick            dw  200 dup('$')

	; variable para almacenar el punteo
	punteo              db  10 dup('$')
	punteoAux           dw  0
	; lista de puntajes desordenados
	puntajes            dw  200 dup('$')
	; lista de puntajes para ordenar
	orderedPoints       dw  200 dup('$')
	; lista de usuarios ya ordenado
	orderedUsersPoints  db  300 dup('$')
	; lista posiciones
	positionsListPoints dw  100 dup('$')

	; variable para almacenar el tiempo
	tiempo              db  10 dup('$')
	tiempoAux           dw  0
	; lista de tiempos desordenados
	tiempos             dw  200 dup('$')
	; lista de tiempos para ordenar
	orderedTimes        dw  200 dup('$')
	; lista de usuarios ya ordenado
	orderedUsersTimes   db  300 dup('$')
	; lista posiciones
	positionsListTimes  dw  100 dup('$')

	; cantidad de registros almacenados
	cont                dw  0
	cont2               dw  0
	cont3               dw  0

	altura              dw  0
	max                 dw  0
	maxP                dw  0
	maxT                dw  0
	base                dw  0
	separacion          dw  10

	i                   dw  0
	j                   dw  0
	k                   dw  0
	interval            dw  0
	temp                dw  0
	tam                 dw  0
	auxTam              dw  0

	valAux              dw  0

	lowP                dw  0
	highP               dw  0
	pi                  dw  0
	pivot               dw  0

	var1                db  0
	var2                db  0
	;================ MENU ADMIN ========================
	opcionAdmin         db  0ah,0dh, '1) TOP 10 PUNTOS',0ah,0dh,'2) TOP 10 TIEMPOS',0ah,0dh,'3) SALIR',0ah,0dh,'$'
	opcionOr            db  0ah,0dh, '1) BUBBLESORT',0ah,0dh,'2) QUICKSORT',0ah,0dh,'3) SHELLSORT',0ah,0dh,'$'
	tipoOrden           db  0ah,0dh, '1) ASCENDENTE',0ah,0dh,'2) DESCENDENTE',0ah,0dh, '$'
	orderType           db  0ah,0dh, 'SELECCIONE EL ORDENAMIENTO',0ah,0dh,'$'
	speedSel            db  0ah,0dh, 'INGRESE VELOCIDAD (0-9): ',0ah,0dh,'$'
	; tipo de orddenamiento
	orderSel            db  0
	;
	speed               db  0
	time                dw  0
	forma               db  0
	beginarr            dw  1 dup('$')
	finisharr           dw  1 dup('$')
	first               dw  0
	last                dw  0

	date                db  '00/00/0000'
	hour                db  '00:00:00'

	msm1                db  0ah,0dh,'INGRESE RUTA: ',0ah,0dh,'$'
	msm2                db  0ah,0dh,'Archivo leido exitosamente!',0ah,0dh,'$'
	msm3                db  0ah,0dh,'Fin de analisis',0ah,0dh,'$'
	msm4                db  0ah,0dh,'Creando Reporte JSON',0ah,0dh,'$'
	msm5                db  0ah,0dh,'Reporte generado exitosamente!',0ah,0dh,'$'
	msm6                db  0ah,0dh,'Regresando al Menu','$'
	msmError1           db  0ah,0dh,'Error al abrir archivo','$'
	msmError2           db  0ah,0dh,'Error al leer archivo','$'
	msmError3           db  0ah,0dh,'Error al crear archivo','$'
	msmError4           db  0ah,0dh,'Error al escribir archivo','$'
	msmError5           db  0ah,0dh,'Debe ser a lo mucho 7 caracteres','$'
	msmError6           db  0ah,0dh,'El usuario ya existe','$'
	msmError7           db  0ah,0dh,'La contrasena debe contener solo numeros','$'
	msmError8           db  0ah,0dh,'La contrasena debe ser de 4 numeros','$'
	msmError9           db  0ah,0dh,'El usuario no existe','$'
	msmError10          db  0ah,0dh,'Contrasena incorrecta','$'
	rutaArchivo         db  100 dup('$')
	rutaUsuarios        db  'users.txt', 00h
	rutaPunteos         db  'users.log', 00h
	bufferLectura       db  1000 dup('$')
	bufferEscritura     db  100 dup('$')
	handleFichero       dw  ?

	aunNo               db  'Metodo no implementado' , '$'
	varAux              db  0
	tipo                db  0

	; ============================ VARIABLES REPORTE ============================
	punto               db  '.', '$'
	numeral             db  '#', '$'
	usuarioT            db  'USER', '$'
	nivel               db  'NIVEL', '$'
	punteoT             db  'PUNTEO', '$'
	tiempoT             db  'TIEMPO', '$'
	segundo             db  's','$'
	user                db  10 dup('$')
	level               db  5 dup('$')
	topPuntaje          db  'TOP 10 PUNTOS', '$'
	topTiempos          db  'TOP 10 TIEMPOS', '$'
	burbuja             db  'BUBBLESORT', '$'
	shell               db  'SHELLSORT', '$'
	quick               db  'QUICKSORT', '$'
	speedLabel          db  'VELOCIDAD: ', '$', '$'
	timeLabel           db  'TIEMPO: 00:00' , '$'

	puntosFile          db  'puntos.rep', 00h
	tiempoFile          db  'tiempos.rep', 00h
	punteoActual        dw  0
	nivelActual         db  49
	ene                 db  'NIVEL', '$', '$'
	
	bandera             db  0
	juegoPerdido        dw  0

	minInicial          db  0
	minFinal            db  0
	segInicial          db  0
	segFinal            db  0
	; ============================ COLORES ============================
	blanco              equ 0fh
	rojo                equ 04h
	azul                equ 20h
	amarillo            equ 0eh
	verde               equ 30h
	morado              equ 05h
	negro               equ 00h
	naranja             equ 2ah

	color               db  0fh

	entra               db  0ah,0dh,'entra','$'
	dis                 db  'Distancia:','$'
	dif                 db  'Diferencia :','$'
	cambio              db  'Cambio:','$'
	temporary           db  'Temporal:','$'
	valJ                db  'Valor J:','$'
	valK                db  'Valor K:','$'
	comp                db  'Comparacion:','$'

	ballX               dw  0
	ballY               dw  0
	; 0, para abajo ; 1 para arriba
	dir                 dw  0
	dirX                dw  0
	dirY                dw  0
	grafX               dw  0
	grafY               dw  0
	posBarra            dw  0
	detectado           db  0
	velocity            dw  200
	siguienteNivel      db  0
	tiempoActual        dw  0
	bloquesQuebrados    dw  0

	tiempoJuego         db  0

	level11             db  11b, 11b, 11b, 11b,
10b, 10b, 10b ,10b,
01b, 01b, 01b, 01b, '$'
	levelJugar          db  100 dup('$')

.code ;segmento de código
;================== SECCION DE CODIGO ===========================
	main proc 
			MOV ax, @data ; obtenemos lo que esta en el segmento de data y lo movemos a ax
			MOV ds, ax  ; enviamos toda la data a ds y asi se puede acceder a las variables
            lecturaArchivos

		Menu:
            print linea
            print encab
            print datos
            print linea
			print inicioRegisto
            print linea
            print eligaop
			getChar
			cmp al,49
			je IniciarSesion
			cmp al,50
			je RegistroSesion
			cmp al,51
			je Salir
			jmp Menu
		IniciarSesion:
			clean usuario, SIZEOF usuario
			clean password, SIZEOF password
			print newUser
            getText usuario
			print newPass
            getText password
			login usuario, password
			jmp Menu
		RegistroSesion:
			clean usuario, SIZEOF usuario
			print newUser
            getText usuario
            ;comparar si el usua esta correcto
            verifyUser usuario
			jmp Contra
		Contra:
			clean password, SIZEOF password
			print newPass
            getText password
			verifyPass password
			addNewUser usuario, password
            clean usuario, SIZEOF usuario
            clean password, SIZEOF password
			jmp Menu
		AdminMenu:
			closeFile      handleFichero
			print linea
			print opcionAdmin 
			print linea
			print eligaop
			getChar
			cmp al,49
			je TopPuntos
			cmp al,50
			je TopTiempo
			cmp al,51
			je Menu
			jmp AdminMenu
		TopPuntos:
			print salto
			mov tipo, 49
			createFile     puntosFile, handleFichero
	        openFile       puntosFile, handleFichero
			pushRecords
			reporteTop topPuntaje, orderedUsersPoints, tipo
			popRecords
			closeFile      handleFichero
			xor ax, ax
			mov ax, maxP
			; colocamos el valor mas alto 
			mov max, ax
			getChar
			ModoVideoOn
			escribirCadena 13, 1, topPuntaje
			pintarCuadro
			pushRecords
			pintarBarras puntajes
			getChar
			popRecords
			clearScreen
			ModoVideoOff
			pushRecords
			transferArray puntajes, orderedPoints
			popRecords
			MenuOrdenamiento orderedPoints
			clean2 orderedPoints, SIZEOF orderedPoints
			transferArray puntajes, orderedPoints
			clean2 orderedTimes, SIZEOF orderedTimes
			transferArray tiempos, orderedTimes
			jmp AdminMenu
		TopTiempo:
			print salto
			mov tipo, 50
			createFile     tiempoFile, handleFichero
	        openFile       tiempoFile, handleFichero
			reporteTop topTiempos, orderedUsersTimes, tipo
			closeFile      handleFichero
			xor ax, ax
			mov ax, maxT
			; colocamos el valor mas alto 
			mov max, ax
			getChar
			ModoVideoOn
			escribirCadena 13, 1, topTiempos
			pintarCuadro
			pushRecords
			pintarBarras tiempos
			getChar
			popRecords
			clearScreen
			ModoVideoOff
			pushRecords
			transferArray tiempos, orderedPoints
			popRecords
			MenuOrdenamiento orderedPoints
			clean2 orderedPoints, SIZEOF orderedPoints
			transferArray puntajes, orderedPoints
			clean2 orderedTimes, SIZEOF orderedTimes
			jmp AdminMenu
		Salir: 
			MOV ah,4ch 
			int 21h
		ErrorCrear:
	    	print msmError3
	    	getChar
	    	jmp Menu
		ErrorEscribir:
	    	print msmError4
	    	getChar
	    	jmp Menu
		ErrorAbrir:
	    	print msmError1
	    	getChar
	    	jmp Menu
		ErrorLeer:
	    	print msmError2
	    	getChar
	    	jmp Menu
	main endp
	quickSort proc ; poceso para quicksort
    push si
    push di
    push dx
    push ax 
	INICIO:
     ;cx begin
     ;bx finish
     cmp cx,bx
	    jl START
	   jmp FIN
	 START:
      
      mov beginarr[0],cx
      mov finisharr[0],bx
	    partition arrQuick,beginarr,finisharr ; macro para hacer el ordenamiento donde puntosarr es el arreglo a ordenar

      
    push dx
    push cx
	  xor si,si
	  mov si,dx
	  dec si
    push bx
    xor bx,bx
    mov bx,si
    call quickSort; llamada recursiva 
    xor bx,bx
    pop bx
    
    xor cx,cx
    pop cx
    xor dx,dx
    pop dx
    
    push dx
    push bx
	  xor si,si
	  mov si,dx
	  inc si
    push cx
    xor cx,cx
    mov cx,si
	  call quickSort; llamada recursiva
    xor cx,cx
    pop cx
    xor cx,cx
    pop bx
    xor dx,dx
    pop dx
	  jmp FIN

	FIN:

    pop ax
    pop dx
    pop di
    pop si	
	ret
quickSort endp
;================ FIN DE SECCION DE CODIGO ========================
end