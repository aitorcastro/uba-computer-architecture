extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_using_c
global alternate_sum_4_using_c_alternative
global alternate_sum_8
global product_2_f
global product_9_f

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4:
  sub EDI, ESI
  add EDI, EDX
  sub EDI, ECX

  mov EAX, EDI
  ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4_using_c:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  push R12
  push R13	; preservo no volatiles, al ser 2 la pila queda alineada

  mov R12D, EDX ; guardo los parámetros x3 y x4 ya que están en registros volátiles
  mov R13D, ECX ; y tienen que sobrevivir al llamado a función

  call restar_c 
  ;recibe los parámetros por EDI y ESI, de acuerdo a la convención, y resulta que ya tenemos los valores en esos registros
  
  mov EDI, EAX ;tomamos el resultado del llamado anterior y lo pasamos como primer parámetro
  mov ESI, R12D
  call sumar_c

  mov EDI, EAX
  mov ESI, R13D
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  pop R13 ;restauramos los registros no volátiles
  pop R12
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


alternate_sum_4_using_c_alternative:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  sub RSP, 16 ; muevo el tope de la pila 8 bytes para guardar x4, y 8 bytes para que quede alineada

  mov [RBP-8], RCX ; guardo x4 en la pila

  push RDX  ;preservo x3 en la pila, desalineandola
  sub RSP, 8 ;alineo
  call restar_c 
  add RSP, 8 ;restauro tope
  pop RDX ;recupero x3
  
  mov EDI, EAX
  mov ESI, EDX
  call sumar_c

  mov EDI, EAX
  mov ESI, [RBP - 8] ;leo x4 de la pila
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  add RSP, 16 ;restauro tope de pila
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[EDI]v, x2[ESI]v, x3[EDX]v, x4[ECX]v, x5[R8D], x6[R9D], x7[RSP], x8[RSP+8]


;[RSP+16] -> X8
;[RSP+8] -> X7
;[RSP] -> RETURN ADRESS
alternate_sum_8: 
	;prologo
  push RBP ;pila alineada
  mov RBP, RSP
  sub RSP, 64 ;hago lugar para EDX, ECX, E8 Y E9 (EDX no hacia falta pero si igual tenia que alinear es lo mismo)

; COMPLETAR
  mov [RBP - 8], EDX ;x3
  mov [RBP - 16], ECX ;x4
  mov [RBP - 24], R8D ;x5
  mov [RBP - 32], R9D ;x6
; [RBP + 16] -> x7
; [RBP + 24] -> x8 ;Pregunta: porque no modificar el rbp para que e vez de empezar en el rsp empezar donde estan los registros? porque los pisas  
  ; [RBP] -> RBP viejo
  ; [RBP+8] -> ret adress

  ; tengo que hacer - + - + ...
  call restar_c ;EAX = x1 - x2

  mov EDI, EAX ;cargo res
  mov ESI, [RBP-8] ; cargo x3
  call sumar_c ;EAX = x1 - x2 + x3

  mov EDI, EAX
  mov ESI, [RBP-16] ; cargo x4
  call restar_c ;EAX = x1 - x2 + x3 - x4

  mov EDI, EAX
  mov ESI, [RBP-24] ; cargo x5
  call sumar_c ;EAX = x1 - x2 + x3 - x4 + x5

  mov EDI, EAX
  mov ESI, [RBP-32] ; cargo x6
  call restar_c ;EAX = x1 - x2 + x3 - x4 + x5 - x6

  mov EDI, EAX
  mov ESI, [RBP+16] ; cargo x7
  call sumar_c ;EAX = x1 - x2 + x3 - x4 + x5 - x6 + x7

  mov EDI, EAX
  mov ESI, [RBP+24] ; cargo x8
  call restar_c ;EAX = x1 - x2 + x3 - x4 + x5 - x6 + x7 - x8

	;epilogo
  add RSP, 64 ;RSP apuntando al tope
  pop RBP ;RBP Restaurado
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[RDI], x1[ESI], f1[XMM0]
product_2_f:
  ;RDI = destination (uint32_t * -> 64 bits) puntero a una direccion
  ;ESI = x1 (uint32_t -> 32 bits)
  ;XMM0 = f1 (float -> 32 bits)

  CVTSS2SD XMM0, XMM0 ; convierto f1 a double
  CVTSI2SD XMM1, ESI ; convierto x1 a double (porque no me da la precicion)  y lo guardo en XMM1
  MULSD XMM0, XMM1 ; multiplico x1 * f1 y lo guardo en XMM0
  CVTTSD2SI EAX, XMM0 ; convierto res en int devuelta
  mov [RDI], EAX ; guardo el resultado en la direccion de destination
  ret


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[esi], f1[xmm0], x2[edx], f2[xmm1], x3[ecx], f3[xmm2], x4[r8], f4[xmm3]
;	, x5[r9], f5[xmm4], x6[?], f6[xmm5], x7[?], f7[xmm6], x8[?], f8[xmm7],
;	, x9[?], f9[?]


;[rsp+48] -> f9
;[rsp+40] -> x9
;[rsp+32] -> x8
;[rsp+24] -> x7
;[rsp+16] -> x6
;[rsp+8] -> return adress
product_9_f:
	;prologo
	push rbp ;[rsp] -> rbp
	mov rbp, rsp ;stack frame creado

	;convertimos los flotantes de cada registro xmm en doubles
	CVTSS2SD xmm0, xmm0 
  CVTSS2SD xmm1, xmm1
  CVTSS2SD xmm2, xmm2
  CVTSS2SD xmm3, xmm3
  CVTSS2SD xmm4, xmm4
  CVTSS2SD xmm5, xmm5
  CVTSS2SD xmm6, xmm6
  CVTSS2SD xmm7, xmm7

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
  MULSD xmm0, xmm1
  MULSD xmm0, xmm2
  MULSD xmm0, xmm3
  MULSD xmm0, xmm4
  MULSD xmm0, xmm5
  MULSD xmm0, xmm6
  MULSD xmm0, xmm7
  CVTSS2SD xmm1, [rbp + 48]
  MULSD xmm0, xmm1 ; xmm0 tiene el res de multiplicar todos los floats

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	CVTSI2SD xmm1, esi
  CVTSI2SD xmm2, edx
  CVTSI2SD xmm3, ecx
  CVTSI2SD xmm4, r8
  CVTSI2SD xmm5, r9
  MULSD xmm0, xmm1
  MULSD xmm0, xmm2
  MULSD xmm0, xmm3
  MULSD xmm0, xmm4
  MULSD xmm0, xmm5 ;tenemos hasta x5

  ;los convierto a double
  CVTSI2SD xmm1, [rbp + 16] ;x6
  CVTSI2SD xmm2, [rbp + 24] ;x7
  CVTSI2SD xmm3, [rbp + 32] ;x8
  CVTSI2SD xmm4, [rbp + 40] ;x9

  ;los multiplico en xmm0
  MULSD xmm0, xmm1
  MULSD xmm0, xmm2
  MULSD xmm0, xmm3
  MULSD xmm0, xmm4 ;xmm0 tiene el resultado

  MOVSD [rdi], xmm0

; epilogo
	pop rbp
	ret

