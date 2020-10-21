;===============SECCION DE MACROS ===========================
include macros.asm
;================= DECLARACION TIPO DE EJECUTABLE ============
.model small 
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
	base                dw  0
	separacion          dw  10
	

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
	speedLabel          db  'VELOCIDAD: ', '$', '$'
	timeLabel           db  'TIEMPO: 00:0' ,'$', '$'
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

	color               db  0fh

	entra           db 0ah,0dh,'entra','$'
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
			reporteTop topPuntaje, orderedUsersPoints, tipo
			xor ax, ax
			mov ax, orderedPoints[0]
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
			pushRecords
			transferArray puntajes, orderedPoints
			popRecords
			clearScreen
			ModoVideoOff
			MenuOrdenamiento orderedPoints
			jmp AdminMenu
		TopTiempo:
			print salto
			mov tipo, 50
			reporteTop topTiempos, orderedUsersTimes, tipo
			xor ax, ax
			mov ax, orderedTimes[0]
			; colocamos el valor mas alto 
			mov max, ax
			getChar
			ModoVideoOn
			escribirCadena 13, 1, topTiempos
			pintarCuadro
			pushRecords
			pintarBarras tiempos
			popRecords
			getChar
			ModoVideoOff
			getChar
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
;================ FIN DE SECCION DE CODIGO ========================
end