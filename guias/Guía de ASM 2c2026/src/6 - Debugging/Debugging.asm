extern strcpy
extern malloc
extern free

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

ITEM_OFFSET_NOMBRE EQU 0
ITEM_OFFSET_ID EQU 12
ITEM_OFFSET_CANTIDAD EQU 16

POINTER_SIZE EQU 8
UINT32_SIZE EQU 4

; Marcar el ejercicio como hecho (`true`) o pendiente (`false`).

global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_3_HECHO
EJERCICIO_3_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_4_HECHO
EJERCICIO_4_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global ejercicio1
ejercicio1:
	; problemas solucionados:
	; logicos:
	; - se suman registros donde noe stan los parametros
	; - se usan registros de 32bits pero los parametros son de 64
	; de convencion:
	; - ebx no se restauraba y es no volatil
	add rdi, rsi
	add rdi, rdx
    add rdi, rcx
    add rdi, r8
	mov rax, rdi
	ret

global ejercicio2
ejercicio2:
	; prologo
	push rbp ;stack alineado
	mov rbp, rsp ;stackframe armado

	mov [rdi+ITEM_OFFSET_ID], esi
	mov [rdi+ITEM_OFFSET_CANTIDAD], edx
	
	add rdi, ITEM_OFFSET_NOMBRE
	mov rsi, rcx
	call strcpy ;listo ahora nombre ya esta donde debe

	mov rax, rdi
	; epilogo
	pop rbp 
	ret


global ejercicio3
ejercicio3:
	; PARAMETROS
	; rdi = arr -> uint32_t* array
	; rsi = n -> uint32_t size, 
	; rdx = fun -> uint32_t (*fun_ej_3)(uint32_t a, uint32_t b)

	;epilogo
	push rbp
	mov rbp, rsp

	push r12
	push r13
	push r14
	push r15
	push rbx
	add rsp, -8

	cmp rsi, 0
	je .vacio
	
	mov r12, rdi ; r12 = array
	mov r13d, 0 ; r13d = resultado parcial (ex r8)
	mov r14d, 0 ; r14d = indice (ex r9)
	mov r15d, esi; r15 = n
	mov rbx, rdx; rbx = fun

	.loop:
	;paso 1: llamo a fun(res(i-1),arr[i-1])
	mov edi, r13d
	mov esi, [r12 + r14*4]

	call rbx ;rax = fun(res(i-1),arr[i-1])

	add r13d, eax ;resultado parcial += fun(res(i-1),arr[i-1])
	mov eax, r13d ;rax = resultado parcial

	inc r14d ;i++
	cmp r14d, r15d ; si  i = n, termino
	je .end

	jmp .loop

	.vacio: ;esto esta bien
	mov rax, 64

	.end:
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

global ejercicio4
; Parametros:
; - rdi = num_arr (64 bits)
; - rsi = size (32 bits)
; - rdx = c (32 bits)
ejercicio4:
	;prologo
	push rbp ;pila alineada
	mov rbp, rsp
	;guardo no vol
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8

	;guardo parametros en no volatiles
	mov r12, rdi ; r12 = puntero a num_arr
	mov r13d, esi ; r13d = size
	mov r14d, edx ; r14d = c

	; alloco memoria para el array
	xor rdi, rdi ;rdi = 0
	mov eax, UINT32_SIZE ;eax = 4
	mul esi ; rax = 4 * size
	mov edi, eax ; edi = 4 * size
	;llamo a malloc
	call malloc ;rax = res_arr
	mov r15, rax ;r15 = res_arr
	
	xor rbx, rbx ;rbx = 0 para usar de contador i
	
	;recorro el array
	.loop:
	
	;hasta i = size
	cmp ebx, r13d
	je .end

	;res_arr[i] = (num_arr[i]*) * c
	mov r8, [r12+rbx*POINTER_SIZE] ;R8 = num_arr[i] (acordate que es un array de punteros)
	mov r9d, [r8] ;r9 = arr[i]* (osea el entero en si: n_i)
	mov eax, r14d ;rax = c
	mul r9d ;eax = c * n_i
	mov [r15+rbx*UINT32_SIZE], eax ;res_arr[i] = c*n_i
	
	;libero num_arr[i]
	mov rdi, r8 
	call free
	;num_arr[i] = null
	mov qword [r12+rbx*POINTER_SIZE], 0
	
	
	;i++ y vuelvo al loop
	inc rbx
	jmp .loop

	.end:
	mov rax, r15 ;rax  tiene el resultado

	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
