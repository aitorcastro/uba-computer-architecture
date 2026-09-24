; Definiciones comunes
TRUE  EQU 1
FALSE EQU 0
NULL EQU 0

; Identificador del jugador rojo
JUGADOR_ROJO EQU 1
; Identificador del jugador azul
JUGADOR_AZUL EQU 2

; Ancho y alto del tablero de juego
tablero.ANCHO EQU 10
tablero.ALTO  EQU 5

; Marca un OFFSET o SIZE como no completado
; Esto no lo chequea el ABI enforcer, sirve para saber a simple vista qué cosas
; quedaron sin completar :)
NO_COMPLETADO EQU -1

extern strcmp

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
carta.en_juego EQU 0
carta.nombre   EQU 1
carta.vida     EQU 14
carta.jugador  EQU 16
carta.SIZE     EQU 18

tablero.mano_jugador_rojo EQU 0
tablero.mano_jugador_azul EQU 8
tablero.campo             EQU 16
tablero.SIZE              EQU 416

accion.invocar   EQU 0
accion.destino   EQU 8
accion.siguiente EQU 16
accion.SIZE      EQU 24

; Variables globales de sólo lectura
section .rodata

; Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - hay_accion_que_toque
global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE

; Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - invocar_acciones
global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE

; Marca el ejercicio 3 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contar_cartas
global EJERCICIO_3_HECHO
EJERCICIO_3_HECHO: db TRUE

section .text

; Dada una secuencia de acciones determinar si hay alguna cuya carta tenga un
; nombre idéntico (mismos contenidos, no mismo puntero) al pasado por
; parámetro.
;
; El resultado es un valor booleano, la representación de los booleanos de C es
; la siguiente:
;   - El valor `0` es `false`
;   - Cualquier otro valor es `true`
;
; ```c
; bool hay_accion_que_toque(accion_t* accion, char* nombre);
; ```
global hay_accion_que_toque
hay_accion_que_toque:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = accion_t*  accion 
	; rsi = char*      nombre

;-PROLOGO
;--Alinear la pila y guardar rbp
push rbp
mov rbp, rsp
;--Reservar lugar en la pila
;--Preservar registros no-volatiles
push r12
push r13
push r14
push r15

;GUARDO PARAMETROS
mov r12, rdi ;r12 = *accion
mov r13, rsi ;r13 = *nombre

;RECORRO ACCIONES
;- seteo resultado en 0
xor r14, r14 ;r14 = res
;while ara iterar
.while:
cmp r12, 0
je .endWhile
	;cargo en parametros direcciones de los nombres a comarar
	lea rdi, [r13] ;rdi = *nombre
	mov rsi, [r12 + accion.destino]
	lea rsi, [rsi + carta.nombre] ;rsi = *nombreCarta
	;comparo nombres, si son iguales sumo, si no sigo
	call strcmp
	cmp rax, 0
	jne .next
	;si son iguales
	inc r14
	jmp .endWhile


.next:
mov r12, [r12 + accion.siguiente] ;actual = actual.siguiente
jmp .while

.endWhile:
mov rax, r14
;-EPILOGO
;-restaurar registros no-volatiles
pop r15
pop r14
pop r13
pop r12
;-liberar lugar de la pila
;-restaurar rbp
pop rbp
    ret

; Invoca las acciones que fueron encoladas en la secuencia proporcionada en el
; primer parámetro.
;
; A la hora de procesar una acción esta sólo se invoca si la carta destino
; sigue en juego.
;
; Luego de invocar una acción, si la carta destino tiene cero puntos de vida,
; se debe marcar ésta como fuera de juego.
;
; Las funciones que implementan acciones de juego tienen la siguiente firma:
; ```c
; void mi_accion(tablero_t* tablero, carta_t* carta);
; ```
; - El tablero a utilizar es el pasado como parámetro
; - La carta a utilizar es la carta destino de la acción (`accion->destino`)
;
; Las acciones se deben invocar en el orden natural de la secuencia (primero la
; primera acción, segundo la segunda acción, etc). Las acciones asumen este
; orden de ejecución.
;
; ```c
; void invocar_acciones(accion_t* accion, tablero_t* tablero);
; ```
global invocar_acciones
invocar_acciones:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = accion_t*  accion
	; rsi = tablero_t* tablero

	;-PROLOGO
;--Alinear la pila y guardar rbp
push rbp
mov rbp, rsp
;--Reservar lugar en la pila
;--Preservar registros no-volatiles
push r12
push r13
push r14
push r15

;PRESERVO PARAMETROS
mov r12, rdi ; r12 = *accion
mov r13, rsi ; r13 = *tablero

;RECORRO ACCIONES
;- while
.while:
cmp r12, 0
je .endWhile
	;busco carta de la accion
	mov r14, qword[r12 + accion.destino] ;r14 = *cartaAccion

	;me fijo que este en el tablero
	cmp r14, NULL
	je .sigAccion
	mov r8b, byte[r14 + carta.en_juego]
	cmp r8b, FALSE
	je .sigAccion

		;si esta en el tablero la invoco
		mov rdi, r13
		mov rsi, r14
		call [r12 + accion.invocar]

		;si tiene cero puntos de vida despues, la marco fuera de jeugo
		mov r8w, word[r14 + carta.vida]
		cmp r8w, 0
		jne .sigAccion
		mov byte[r14 + carta.en_juego], FALSE

.sigAccion:
mov r12, qword[r12 + accion.siguiente]
jmp .while


.endWhile:

;-EPILOGO
;-restaurar registros no-volatiles
pop r15
pop r14
pop r13
pop r12
;-liberar lugar de la pila
;-restaurar rbp
pop rbp
    ret

	ret

; Cuenta la cantidad de cartas rojas y azules en el tablero.
;
; Dado un tablero revisa el campo de juego y cuenta la cantidad de cartas
; correspondientes al jugador rojo y al jugador azul. Este conteo incluye tanto
; a las cartas en juego cómo a las fuera de juego (siempre que estén visibles
; en el campo).
;
; Se debe considerar el caso de que el campo contenga cartas que no pertenecen
; a ninguno de los dos jugadores.
;
; Las posiciones libres del campo tienen punteros nulos en lugar de apuntar a
; una carta.
;
; El resultado debe ser escrito en las posiciones de memoria proporcionadas
; como parámetro.
;
; ```c
; void contar_cartas(tablero_t* tablero, uint32_t* cant_rojas, uint32_t* cant_azules);
; ```
global contar_cartas
contar_cartas:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = tablero_t* tablero
	; rsi = uint32_t*  cant_rojas
	; rdx = uint32_t*  cant_azules

;limpio para usar contadores
mov dword[rsi], 0
mov dword[rdx], 0

lea r9, [rdi + tablero.campo]
;recorro tablero
xor rcx, rcx ;rcx = fila
.cicloFilas:
cmp rcx, tablero.ALTO
je .terminarCiclo

	xor rax, rax ;rax = col
	.cicloCol:
	cmp rax, tablero.ANCHO
	je .sigFila

		; Calcular índice lineal: (fila * ANCHO + col)
		mov r11, rcx                ; r11 = fila
		imul r11, tablero.ANCHO     ; r11 = fila * ANCHO
		add r11, rax                ; r11 = fila * ANCHO + col

		; Cargar el puntero a la carta actual (cada puntero ocupa 8 bytes)
		mov r8, [r9 + r11 * 8]      ; r8 = campo[índice]

		;chequeo que no sea null
		cmp r8, NULL
		je .sigCol
		;
			mov r10b, byte[r8 + carta.jugador]
			cmp r10b, JUGADOR_AZUL
			je .sumarJugadorAzul
			cmp r10b, JUGADOR_ROJO
			je .sumarJugadorRojo
			jmp .sigCol

			.sumarJugadorAzul:
			inc dword[rdx]
			jmp .sigCol

			.sumarJugadorRojo:
			inc dword[rsi]
			jmp .sigCol


	.sigCol:
	inc rax
	jmp .cicloCol

.sigFila:
inc rcx
jmp .cicloFilas

.terminarCiclo:

ret
