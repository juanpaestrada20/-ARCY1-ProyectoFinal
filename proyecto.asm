;===============SECCION DE MACROS ===========================
include macros.asm
;================= DECLARACION TIPO DE EJECUTABLE ============
.model small 
.stack 100h 
.data
	;================ INICIO DE SESION ========================
	linea           db '----------------------------------------------------------------------------', '$'
	encab           db 0ah,0dh, 'UNIVERSIDAD DE SAN CARLOS DE GUATEMALA', 0ah,0dh,'FACULTAD DE INGENIERIA',0ah,0dh,'CIENCIAS Y SISTEMAS',0ah,0dh,'ARQUITECTURA DE COMPUTADORES 1' ,
0ah,0dh,'SECCION A',0ah,0dh,'Proyecto 2','$'
	datos           db 0ah,0dh, 09h, 09h, 'JUAN PABLO ESTRADA ALEMAN', 0ah,0dh, 09h, 09h, 09h, '201800709',0ah,0dh,'$'
	inicioRegisto   db 0ah,0dh, '1) INGRESAR',0ah,0dh,'2) REGISTRARSE',0ah,0dh,'3) SALIR',0ah,0dh,'$'
	eligaop         db 0ah, 0dh, 'Elija una opcion: ', '$'
	salto           db 0ah, 0dh , '$'
	
	;================ USUARIOS ========================
	newUser         db 0ah, 0dh, 'Ingrese el usuario: ', '$'
	newPass         db 'Ingrese el password: ', '$'
	usuario         db 15 dup('$')                                                                                                                                                 	;
	password        db 10 dup('$')                                                                                                                                                 	;
	adminUser       db 'adminAI','$'
	adminPass       db '4321', '$'
	listaUsuarios   db 3000 dup('$')
	auxUser         db 100 dup('$')


	date            db '00/00/0000'
	hour            db '00:00:00'

	msm1            db 0ah,0dh,'INGRESE RUTA: ',0ah,0dh,'$'
	msm2            db 0ah,0dh,'Archivo leido exitosamente!',0ah,0dh,'$'
	msm3            db 0ah,0dh,'Fin de analisis',0ah,0dh,'$'
	msm4            db 0ah,0dh,'Creando Reporte JSON',0ah,0dh,'$'
	msm5            db 0ah,0dh,'Reporte generado exitosamente!',0ah,0dh,'$'
	msm6            db 0ah,0dh,'Regresando al Menu','$'
	msmError1       db 0ah,0dh,'Error al abrir archivo','$'
	msmError2       db 0ah,0dh,'Error al leer archivo','$'
	msmError3       db 0ah,0dh,'Error al crear archivo','$'
	msmError4       db 0ah,0dh,'Error al escribir archivo','$'
	msmError5       db 0ah,0dh,'Comando no reconocido','$'
	rutaArchivo     db 100 dup('$')
	rutaUsuarios    db 'users.txt', 00h
	rutaPunteos     db 'users.log', 00h
	bufferLectura   db 3000 dup('$')
	bufferEscritura db 100 dup('$')
	handleFichero   dw ?

	aunNo           db 'Metodo no implementado' , '$'

	; ============================ VARIABLES REPORTE ============================
	
	
	entra           db 0ah,0dh,'entra','$'
.code ;segmento de código
;================== SECCION DE CODIGO ===========================
	main proc 
			MOV ax, @data ; obtenemos lo que esta en el segmento de data y lo movemos a ax
			MOV ds, ax  ; enviamos toda la data a ds y asi se puede acceder a las variables

		Menu:
            lecturaArchivos
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
			print aunNo
			jmp Menu
		RegistroSesion:
			print newUser
            getText usuario
            verifyUser newUser
            ;comparar si el usuario esta correcto
			print newPass
            getText password
            clean usuario, SIZEOF usuario
            clean password, SIZEOF password
			jmp Menu
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