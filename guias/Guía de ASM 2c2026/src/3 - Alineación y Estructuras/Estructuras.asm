

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
NODO_OFFSET_NEXT EQU 0
NODO_OFFSET_CATEGORIA EQU 8
NODO_OFFSET_ARREGLO EQU 16
NODO_OFFSET_LONGITUD EQU 24
NODO_SIZE EQU 32
PACKED_NODO_OFFSET_NEXT EQU 0
PACKED_NODO_OFFSET_CATEGORIA EQU 8
PACKED_NODO_OFFSET_ARREGLO EQU 9
PACKED_NODO_OFFSET_LONGITUD EQU 17
PACKED_NODO_SIZE EQU 21
LISTA_OFFSET_HEAD EQU 0
LISTA_SIZE EQU 8
PACKED_LISTA_OFFSET_HEAD EQU 0
PACKED_LISTA_SIZE EQU 8

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[RDI]
cantidad_total_de_elementos:
	mov rdi, [rdi + LISTA_OFFSET_HEAD]; RDI = puntero al primer nodo
	
	xor rax, rax ; limpio rax y lo uso de contador (rax = 0)
	cmp rdi, 0 ;verifico que haya al menos un elemento
	je .retorno ;si no hay, retorno
	
	.ciclo:
		add eax, dword [rdi + NODO_OFFSET_LONGITUD] ;eax += longitud
		mov rdi, [rdi + NODO_OFFSET_NEXT] ; tengo en rdx el puntero al proximo
		cmp rdi, 0
		jne .ciclo ;si hay next vuelvo.

	.retorno:
		ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos_packed:
	mov rdi, [rdi + PACKED_LISTA_OFFSET_HEAD]; RDI = puntero al primer nodo
	
	xor rax, rax ; limpio rax y lo uso de contador (rax = 0)
	cmp rdi, 0 ;verifico que haya al menos un elemento
	je .retorno ;si no hay, retorno
	
	.ciclo:
		add eax, dword [rdi + PACKED_NODO_OFFSET_LONGITUD] ;eax += longitud
		mov rdi, [rdi + PACKED_NODO_OFFSET_NEXT] ; tengo en rdx el puntero al proximo
		cmp rdi, 0
		jne .ciclo ;si hay next vuelvo.

	.retorno:
	ret

