extern malloc
extern strcpy

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - optimizar
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contarCombustibleAsignado
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
;offsets son
ATTACKUNIT_CLASE EQU 0
ATTACKUNIT_COMBUSTIBLE EQU 12
ATTACKUNIT_REFERENCES EQU 14
ATTACKUNIT_SIZE EQU 16

global optimizar
optimizar:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = mapa_t           mapa (puntero a al inicio del mapa)
	; rsi = attackunit_t*    compartida
	; rdx = uint32_t*        fun_hash(attackunit_t*)

	;--PROLOGO--
	push rbp
	mov rbp, rsp
	sub rsp, 32
	push r12
	push r13
	push r14
	push r15

	;guardo parametros en el stackframe ya que llamo a funhash
	
    mov [rbp-8], rdi   ; [rbp-8]  = mapa (8 bytes)
    mov [rbp-16], rsi  ; [rbp-16] = compartida (8 bytes)
    mov [rbp-24], rdx  ; [rbp-24] = fun_hash (8 bytes)
    ; [rbp-32] no tiene nada, solo alinea

	;--FIN PROLOGO--


	;calculo el has de la compartida para comparar
	mov rdi, rsi
	call rdx 
	mov r12, rax; ;r12 = hashAcomparar

	;traigo los parametros
	;mov r8, [rbp-8] ;r8 = mapa
	;mov r9, [rbp-16] ;r9 = compartida
	;mov r10, [rbp-24] ;r10 = funhash

	;recorro el mapa
	xor r13, r13 ;i = 0
	.cicloi:
		xor r14, r14 ;j = 0
		.cicloj:
		;BUSCO PUNTERO UNIDAD ACTUAL
			mov r8, [rbp-8] ;r8 = mapa

			mov rax, r13
			imul rax, 255
			add rax, r14
			shl rax, 3
			mov r15, [r8 + rax];r15 = pUnidadActual
		
		;CALCULO HASH UNIDAD ACTUAL SOLO SI NO ES NULL
			;chequeo que no sea null
			cmp r15, 0
			je .sigElemento
			;si no es null calculo hashUnidadActual
			mov r10, [rbp-24] ;r10 = funhash
			mov rdi, r15
			call r10; rax = hashUnidadActual

		;ya no llamo a funciones con lo cual es seguro traer los parametros
			mov r8, [rbp-8] 	;r8 = mapa
			mov r9, [rbp-16] 	;r9 = compartida
			mov r10, [rbp-24] 	;r10 = funhash
								;r12 = hashAcomparar
								;r15 = pUnidadActual
								;rax = hashUnidadActual

		;COMPARO CON LA QUE TENGO QUE BUSCAR, SI CORRESPONDE HAGO EL CAMBIO
			cmp  r12, rax
			je .checkNoSonLaMisma
			jmp .sigElemento
			.checkNoSonLaMisma:
			cmp r9, r15
			je .sigElemento
			
			;tienen el mismo hash pero son diferentes punteros
			;decremento las referencias de la actual
			movzx r11, byte [r15 + 14] ;r11 es las referencias de la actual
			cmp r11, 0
			jle .hagoElCambio
			dec r11
			mov byte [r15 + 14], r11b

			.hagoElCambio:
			mov rax, r13
			imul rax, 255
			add rax, r14
			shl rax, 3
			mov [r8 + rax], r9

			movzx r11, byte [r9 + 14]
			inc r11
			mov byte [r9 + 14], r11b

			.sigElemento:
				cmp r14, 254
				je .sigFila
				inc r14
				jmp .cicloj
		.sigFila:
			cmp r13, 254
			je .termineRecorrerMapa	
			inc r13
			jmp .cicloi

	.termineRecorrerMapa:
	pop r15
	pop r14
	pop r13
	pop r12
	add rsp, 32
	pop rbp
	ret


global contarCombustibleAsignado
contarCombustibleAsignado:
	; rdi = mapa_t           mapa
	; rsi = uint16_t*        fun_combustible(char*)

	;--PROLOGO INICIO--
	push rbp
	mov rbp, rsp
	;pido espacio para guardar el res
	sub rsp, 8

	;guardo no volatiles
	push r12
	push r13
	push r14
	push r15
	push rbx
	
	
	mov dword [rbp-8], 0
	;--PROLOGO FIN--

	;guardo parametros en no volatiles
	mov r12, rdi ;r12 = mapa
	mov r13, rsi ;r13 = fun_combustible

	;recorro el mapa
	xor r14, r14 ;i=0
	.cicloi:
		xor r15, r15 ;j=0
		.cicloj:
			;COMPARAR COMBUSTIBLES SI CORREPONDE ACTUALIZAR RESULTADO
			;calculo unidad actual
			mov rbx, r14
			imul rbx, 255
			add rbx, r15
			shl rbx, 3 
			mov rbx, [rbx + r12];rbx = pUnidadActual

			;chequeo que no sea null
			cmp rbx, 0
			je .sigElemento

			;calculo combustible base
			mov rdi, rbx
			call r13;rax = combustibleBase

			;calculo combustibleActual
			movzx r8, word [rbx + 12] ;r8 = combustibleActual

			;comparo combustibleActual > combustibleBase
			cmp r8, rax 
			jle .sigElemento
			sub r8, rax
			mov r9d, [rbp-8]
			add r9, r8
			mov dword [rbp-8], r9d


			.sigElemento:
			cmp r15, 254
			je .sigFila
			inc r15
			jmp .cicloj

		.sigFila:
		cmp r14, 254
		jge .termineRecorrerMapa
		inc r14
		jmp .cicloi

	.termineRecorrerMapa:
	mov eax, [rbp -8]
	;--EPILOGO INICIO--
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	add rsp, 8
	pop rbp
	;--EPILOGO FIN--
	ret 

global modificarUnidad
modificarUnidad:
	; rdi = mapa_t           mapa
	; sil  = uint8_t          x
	; dl  = uint8_t          y
	; rcx = void*            fun_modificar(attackunit_t*)

	;--PROLOGO INICIO--
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15

	;--PROLOGO FIN--

	;--guardo parametros en no volatiles--
	;r12 = fun
	;r13 = pUnidadAModificar = mapa[x][y]
	;r14 = mapa + (x*255+y)*8
	;--
	mov r12, rcx ;r12 = fun

	;para lo otro no necesito los tres, solo la posicion en si
	;calculo: mapa + (x*255+j)*8
	movzx r14, sil;r14 = x
	imul r14, 255;r14 = x*255
	movzx r9, dl;r9 = y
	add r14, r9 ;r14 = x*255+y
	shl r14, 3;r14 = (x*255+y)*8
	add r14, rdi ;r14 = mapa + (x*255+y)*8

	;cargo en r13 el puntero de la posicion que me importa
	mov r13, [r14] ; r13 = pUnidadAModificar mapa[x][y]

	;--me fijo que no sea null
	cmp r13, 0
	je .termine

	;--me fijo si es una unidad compartida
	movzx r8, byte [r13 + 14] ;r8 = pUnidadAModificar->references
	cmp r8, 1
	jle .modificar

	;--si es compartida
		;-decremento las referencias
		dec r8
		mov byte [r13 + 14], r8b

		;-aloco memoria para la nueva unidad
		mov rdi, 16
		call malloc 
		mov r15, rax ;r15 = pNuevaUnidad

		;-copio los datos a la nueva unidad
		;1) copio clase
		lea rdi, [r15]
		lea rsi, [r13]
		call strcpy ;clase listo
		;2) copio combustible
		movzx r8, word [r13 + 12]
		mov word [r15 + 12], r8w ;combustible listo
		;3) modifico referencias
		mov byte [r15 + 14], 1

		;-la modifico
		mov rdi, r15
		call r12

		;-modifico el mapa
		mov qword [r14], r15

		jmp .termine

	.modificar:
	mov rdi, r13
	call r12 ;fun(pUnidadAModificar)

	.termine:
	;--EPIlOGO INICIO--
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	;--EPILOGO FIN--
	ret

	;r12 = fun
	;r13 = pUnidadAModificar = mapa[x][y]
	;r14 = mapa + (x*255+y)*8
	;r15 = pNuevaUnidad

	; ATTACKUNIT_CLASE EQU 0
	; ATTACKUNIT_COMBUSTIBLE EQU 12
	; ATTACKUNIT_REFERENCES EQU 14
	; ATTACKUNIT_SIZE EQU 16
