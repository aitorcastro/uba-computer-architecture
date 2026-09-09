extern malloc

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
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_NOMBRE EQU 0
ITEM_FUERZA EQU 20
ITEM_DURABILIDAD EQU 24
ITEM_SIZE EQU 28

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.

global es_indice_ordenado
es_indice_ordenado:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = item_t**     inventario
	; rsi = uint16_t*    indice
	; dx = uint16_t     tamanio
	; rcx = comparador_t comparador

	;prologo:
	push rbp ;pila alineada
	mov rbp, rsp ;stack frame armado

	push rbx
	push r12
	push r13
	push r14
	push r15

	sub rsp, 8 ; alineo la pila

	;guardo parametros en no volatiles
	mov rbx, rdi ;rbx = item_t**     inventario
	mov r12, rsi ; r12 = uint16_t*    indice
	movzx r13, dx ; r13 = uint16_t     tamanio
	mov r14, rcx; r14 = comparador_t comparador
	xor r15, r15
	inc r15 ;r15 = j
	sub r13, 1; r13 = tamanio -1

	.ciclo:
	mov r8, r15
	sub r8, 1 ;r8 = i = j-1

	xor rdi, rdi
	mov di, word [r12 + r8 * 2] ;rdi = indice[i]
	xor rsi, rsi
	mov si, word [r12 + r15 * 2] ;rsi = indice[j]

	mov rdi, [rbx + rdi * 8] ;rdi = inventaro[indice[i]]
	mov rsi, [rbx + rsi * 8] ;rsi = inventario[indice[j]]

	call r14 ;rax = cumplen_orden?
	;si no cumplen salto
	cmp rax, 0
	je .return

	;si cumplen, sigo (rax ya tiene el true de antes)
	;verifico que no termine de recorrer
	cmp r15, r13 ; j == tamanio - 1?
	je .return ;si termine salto
	inc r15 ;j++
	jmp .ciclo
	

	.return:
	;epilogo
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
		ret

;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
indice_a_inventario:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = item_t**  inventario (puntero al inicio de un array de punteros a items)
	; rsi = uint16_t* indice (puntero al inicio de un array de enteros de 16bits(indices))
	; dx = uint16_t  tamanio (entero de 16 bits)

	;prologo
	push rbp ;pila alineada	
	mov rbp, rsp

	;guardo los parametros en no volatil
	;primero salvo los registros
	push r12
	push r13
	push r14
	push r15 
	push rbx 
	sub rsp, 8 ;pila alineada

	;ahora guardo los parametros que quiero mantener antes del malloc
	mov r12, rdi ;r12 = inventario
	mov r13, rsi ;r13 = indice
	movzx rbx, dx ;rbx = tamanio
	xor r15, r15 ;r15 = i 

	;cuerpo
	;aloco memoria
	mov rdi, rbx ;rdi = tamanio
	shl rdi, 3 ;rdi = tamanio * 8
	call malloc ;rax = resultado
	mov r14, rax ;r14= resultado

	;redusco el tamanio ya que para el ciclo me sirve tamanio- 1
	sub rbx, 1

	;traslado el array
	.ciclo:
		;extraigo el puntero al item
		movzx rdi, word [r13 + r15 * 2] ;rdi = indice[i]
		mov rdi, [r12 + rdi * 8] ;rdi = inventario[indice[i]]

		;pongo el puntero al item en i enresultado
		mov [r14 + r15*8], rdi ;resultado[i] = inventario[indice[i]]

		;chequeo fin de ciclo
		;si i >= tamanio - 1 termino, si no i++
		cmp r15, rbx 
		je .fin
		inc r15
		jmp .ciclo

	.fin:
		mov rax, r14 ;rax = resultado
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
