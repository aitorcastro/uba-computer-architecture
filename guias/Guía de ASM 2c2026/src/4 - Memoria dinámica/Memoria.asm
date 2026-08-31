extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
; PARAMETROS
;	- rdi = a (puntero a primer char del string a)
; 	- rsi = b (puntero a primer char del string b)
strCmp:
	xor eax, eax ;Limpio eax pq voy a poner el resultado: 0 si a=b, 1 si a<b, -1 si a>b
	;hago un ciclo comparando char a char a y b
	.ciclo:
		;cargo los caracteres actuales a registros de 8 bits
		mov cl, byte [RDI] ;cl = a[i]
		mov dl, byte [rsi] ;dl = b[i]
		;chequeo los chars ai y bi que tengo,si llego a '\0' en una y otra no entonces esa palabr es mas chica
		;si ai = bi ='\0' son iguales -> rax =  0
		cmp cl, dl
		jb .menor ;si a[i] < b[i] ->  a < b
		ja .mayor ;si a[i] > b[i] -> a > b
		je .iguales

	;a = b
	.iguales:
		cmp cl, 0
		;si son iguales y terminaron son iguales
		je .retIguales

		;si son iguales pero no terminaron sigo iterando
		inc rdi
		inc rsi
		jmp .ciclo
	;a < b
	.menor: 
		mov eax, 1;
		jmp .retornar
	;a > b
	.mayor: 
		mov eax, -1;
		jmp .retornar
	
	.retIguales:
		mov eax, 0
	.retornar:
	ret

; char* strClone(char* a)
; PARAMETROS
; - rdi = a (puntero al primer caracter de a)
strClone:
	;la idea va a ser ir recorriendo a char a char, copiandolos en otra direccio
	;voy a necesitar llamar a malloc y free por lo que necesito epilogo y prologo
	;voy a necesitar strLen primero para saber cuanta memoria pedir
	; PROLOGO
	push rbp ; pila alineada, guardo rbp
	mov rbp, rsp; stack frame armado
	push r12 ;para guardar a ya que rdi es volatil
	push r13 ;para guardar el resultado y alinear la pila a 16

	; CUERPO
	mov r12, rdi ;r12 = a
	; primero necesito longitud de a uso strLen
	; a ya esta en rdi
	call strLen ;rax = longitud de a

	; ahora necesito alocar memoria uso malloc
	mov rdi, rax
	inc rdi ;rdi = length(a)+1 (para '\0')
	call malloc ;rax = puntero nuevo b para el clon
	mov r13, rax ;r13 = b

	; ahora si, itero a copiando a[i] en b[i], si llego a '\0' termino
	xor rdx, rdx ;indice
	.ciclo:
		mov cl, byte [r12 + rdx] ;cl = a[i]
		mov [r13 + rdx], cl ;a[i] = b[i]
		test cl, cl ;si es '\0'
		jz .retornar
		
		inc rdx
		jmp .ciclo


	; EPILOGO
	.retornar:
	mov rax, r13
	pop r13 
	pop r12
	pop rbp
	ret

; void strDelete(char* a)
; PARAMETROS:
; - rdi = a
strDelete:
	;quiero simplemente hacer free(a) y no quiero preservar nada, luego
	jmp free
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	ret
 
; uint32_t strLen(char* a)
; PARAMETROS:
; - rdi = a (puntero al primer caracter de a)
strLen:
	; la idea va a ser recorrer a incrementando un contador hasta llegar a '\0'
	
	xor eax, eax ; rax va a ser mi contador, inicializo en 0
	.ciclo:
		mov cl, byte [rdi] ;paso el char a un registro mas chico para poder comparar vs '\0'
		;si a[i] = '\0' termine, no lo cuento, retorno rax
		test cl, cl
		jz .retornar
		;si a[i] != '\0' no termine, sigo
		inc eax
		inc rdi
		jmp .ciclo
	.retornar:
	ret


