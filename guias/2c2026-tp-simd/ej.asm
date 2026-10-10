; Hace que los accesos a memoria por defecto se compilen como [rip + offset]
; en lugar de [offset_desde_el_0x0].
;
; Ver https://www.nasm.us/doc/nasmdoc7.html#section-7.2.1 para más información
DEFAULT REL

TRUE  EQU 1
FALSE EQU 0

SINCOS_SIN_OFF EQU 0
SINCOS_COS_OFF EQU 4
SINCOS_SZ      EQU 8

section .rodata

global ej_1_hecho
global ej_2_hecho
global ej_3_hecho
global ej_4_hecho
ej_1_hecho: db TRUE
ej_2_hecho: db TRUE
ej_3_hecho: db TRUE
ej_4_hecho: db TRUE

ALIGN 16
espacios:
	times 10 db ' ' - '0'
	times 6  db 0x0
ceros:
	times 10 db '0'
	times 6  db 0x0
; ... y otra data que les resulte útil para resolver los ejercicios


;MI DATA

;dos en float para mulss
ALIGN 16
dos_float: dd 2.0

;mascara de ceros para usar como indices para replicar el primer elemento en un registro
ALIGN 16
c: times 16 db 0

;mascaras para asignarle pesos al valor en ejercicio 4.
;mascara 1 para multiplicar pares por 10 e inpares por 1
ALIGN 16
mult_10_1:
    db 10, 1, 10, 1, 10, 1, 10, 1, 10, 1, 0, 0, 0, 0, 0, 0

;mascara 2 para multiplicar por 100
ALIGN 16
mult_100_1:
    dw 100, 1, 100, 1, 1, 0, 0, 0

;para 10000
ALIGN 16
mult_10000_1:
    dd 10000, 1, 1, 0 

;ultimo * 100 para el segundo bloque
ALIGN 16
mult_100_qword:
    dq 100, 0 

section .text

global ej1_sample
; void ej1_sample(size_t buf_len, int16_t buf[buf_len],
;                 size_t freq_a_len, int16_t freq_a[freq_a_len], size_t a_start,
;                 size_t freq_b_len, int16_t freq_b[freq_b_len], size_t b_start);
;
; buf_len:    Está en rdi
; buf:        Está en rsi
; freq_a_len: Está en rdx
; freq_a:     Está en rcx
; a_start:    Está en r8
; freq_b_len: Está en r9
; freq_b:     Está en [rbp + 16]
; b_start:    Está en [rbp + 24]
;
; Tener en mente que:
; - buf_len, freq_a_len, freq_b_len, a_start y b_start son siempre múltiplos de 16
; - a_start < freq_a_len y b_start < freq_b_len
; - freq_a y freq_b están dados tal que sumarlos entre sí no causa overflow



;PARAMETROS
;- rdi = bufLen (8B / 64b)
;- rsi = buf arreglo de datos de 16b
;- rdx = freq a len
;- rcx = freq a  arreglo de datos de 16b
;- r8 = freq a start
;- r9 = freq b len 
;- [rbp + 16] = freq b arregloo de datos de 16b
;- [rbp + 24] = freq b start

ej1_sample:
;prologo
push rbp 
mov rbp, rsp; [rbp] = rbp
push r12
push r13

mov r13, [rbp + 16] ;r13 = freqB
mov r11, [rbp + 24] ;r11 = freq b start

;multiplico todos los starts y lens por 2 para iterar de a bytes
shl r8, 1
shl rdx, 1
shl r11, 1
shl r9, 1
shl rdi, 1

;RECORRO EL BUFFER
xor r10, r10 ;i = 0

.ciclo:
;i >= largo?
cmp r10, rdi
jge .finCiclo

	;PROCESAMOS DE A 8 ELEMENTOS (16 BYTES) A LA VEZ
	;cargo 8 elementos de freq a en xmm0
	cmp r8, rdx
	jne .aIndexOk
	xor r8, r8
	.aIndexOk:
	movdqu xmm0, [rcx + r8]
	add r8, 16

	;cargo 8 elementos de freq b en xmm1
	cmp r11, r9
	jne .bIndexOk
	xor r11, r11
	.bIndexOk:
	movdqu xmm1, [r13 + r11]
	add r11, 16

	;sumo en xmm0
	paddw xmm0, xmm1
	;divido por 2 (shr 2)
	psraw xmm0, 1

	;guardo en el buffer
	movdqu [rsi + r10], xmm0


.sigElemento:
add r10, 16 ;avanzo de a 8 elementos, 16 bytes
jmp .ciclo
.finCiclo:

;epilogo
pop r13
pop r12
pop rbp
ret

global ej2_detect
; float ej2_detect(size_t size, int16_t signal[size], sincos_t freq[size]);
;
; size:   Está en rdi
; signal: Está en rsi
; freq:   Está en rdx
ej2_detect:
	;creo re y im
	xorps xmm8, xmm8
	xorps xmm9, xmm9
	
	xor r10, r10 ;i = 0
	.ciclo:
	;i >= largo?
	cmp r10, rdi
	jge .finCiclo

		;cuerpo ciclo
		;LEVANTO DOS SIGNALS
		;muevo dos signals a la parte baja de xmm0
		movd xmm0, [rsi + r10 * 2] ;xmm0: [0, 0, 0, 0, 0, 0, sig1, sig0]

		;expando a 32 bits
		pmovsxwd xmm0, xmm0 ;xmm0: [0, 0, sig1, sig0]
		
		;convertir a float
		cvtdq2ps xmm0, xmm0 ;xmm0: [0.0, 0.0, float(sig1), float(sig0)]

		;unpack para "duplicarlos"
		unpcklps xmm0, xmm0 ;xmm0: [sig1, sig1, sig0, sig0]

		;LEVANTO LAS FREQ (8 words / 4 dwords)
		movdqu xmm1, [rdx + r10 * 8] ;xmm1: [cos1, sin1, cos0, sin0]

		;MULTIPLICO POR LAS FREQ
		mulps xmm0, xmm1 ;xmm0: [sig1*cos1, sig1*sin1, sig0*cos0, sig0*sin0]

		;ACUMULO
		addps xmm8, xmm0 ;xmm8: [Sum_Re_Impares, Sum_Im_Impares, Sum_Re_Pares, Sum_Im_Pares]

	.sigElemento:
	add r10, 2 ;voy moviendo de a words
	jmp .ciclo
	.finCiclo:

	;CALCULO RESULTADO
	;calculo re y im
	movdqu xmm9, xmm8
	psrldq xmm9, 8
	addps xmm8, xmm9 ;xmm8: [..., ..., Re_Total, Im_Total]

	;calculo cuadrados
	mulps xmm8, xmm8 ;xmm8: [..., ..., Re^2, Im^2]

	;calculo suma
	HADDPS xmm8, xmm8 ;xmm8: [..., ..., ..., (Re^2 + Im^2)]

	;calculo raiz
	sqrtss xmm8, xmm8

	;multiplico por 2
	mulss xmm8, [dos_float]

	;divido por size
	cvtsi2ss xmm9, rdi
	divss xmm8, xmm9

	xorps xmm0, xmm0
	movaps xmm0, xmm8
	ret

global ej3_remove_duplicates
; void ej3_remove_duplicates(size_t size, char detected[size], char output[]);
;
; size:   Está en rdi
; detected: Está en rsi
; output: Está en rdx
ej3_remove_duplicates:
	;SETUP DE INDICES ETC
	;indice para el output
	xor r8, r8 ;r8 = outi

	;senial de referencia
	mov r9b, ' '

	;RECORRO DETECTED DE A 16 ELEMENTOS (16 BYTES)
	xor r10, r10 ;i = 0
	.ciclo:
	;i >= largo?
	cmp r10, rdi
	jge .finCiclo

		;cargo un bloque de 16 elementos
		movdqu xmm0, [rsi + r10] 

		;COMPARO SI SON TODOS IGUALES
		;agarro el primer byte de xmm0 y lo replico en todo xmm1
		movdqa  xmm1, xmm0 
		pshufb  xmm1, [c] ;uso una mascara de ceros para que todos  los indices que use pshufb sean 0

		;chequeo si son iguales
		pcmpeqb xmm0, xmm1
		pmovmskb r11d, xmm0 ;muevo los 16 bits mas sigfnificativos a r11d
		cmp r11d, 0xFFFF ;comparo

		;si no son iguales sigElemento
		jne .sigElemento

		;comparo detected[i] (puedo usar al que apunte r10 porque aca son todos iguales) con la senial de referencia (r9)
		mov r11b, byte[rsi + r10]
		cmp r9b, r11b
		je .sigElemento

		;guardo como nueva referencia detected[i]
		mov r9b, r11b

		;si es espacio sigo
		cmp r9b, ' '
		je .sigElemento

		;actualizo output con detected[i]
		mov byte[rdx + r8], r11b
		
		;actualizo indice de output
		inc r8

	.sigElemento:
	add r10, 16
	jmp .ciclo
	.finCiclo:
	ret

global ej4_get_numbers
; void ej4_get_numbers(size_t size, char numbers[10 * (size - 1) + 16], size_t output[size]);
;
; size:   Está en rdi
; signal: Está en rsi
; output: Está en rdx
ej4_get_numbers:

	;indice para output
	xor r8, r8

	;recorro los numeros
	xor r10, r10 ;i = 0
	imul rdi, 10
	.ciclo:
	;i >= largo?
	cmp r10, rdi
	jge .finCiclo
		
		;CONVIERTO DE ASCCI A DIJITOS
		;leo un bloque de 10 numeros (ignoro lso ultimos 4)
		movdqu xmm0, [rsi + r10]

		;les resto '0'
		psubb xmm0, [ceros]

		;normalizo los espacios
		movdqa xmm1, xmm0
		pcmpeqb xmm1, [espacios]; xmm1 = 0xFF donde es espacio, 0x00 donde es num
		pand xmm1, [espacios] ; xmm1 = -16 donde es espacio, 0 donde es num
		psubb xmm0, xmm1 ;resto 16 a los espacios y dejo igual los num
		
		;xmm0 tiene los diez dijitos limpios

		;CALCULO EL VALOR FINAL
		;junto en pares de dijitos (dwords) donde:
		;	par_i = d_i * 10 + d_i+1

		;- par[0] = (d0*10+d1), 
		;- par[1] = (d2*10+d3), 
		;- par[2] = (d4*10+d5), 
		;- par[3] = (d6*10+d7),
		;- par[4] = (d8*10+d9)
		pmaddubsw xmm0, [mult_10_1] ; xmm0 = [par[0], par[1], par[2], par[3], par[4], 0, 0, 0 ]

		;junto en dos bloques de 4 y uno de 2 donde: 
		;	bloque_i = (d_i * 10 + d_i+1) * 100 + (d_i+2 * 10 + d_i+3)
		;	exepto el ultimo que queda igual (d_8 * 10 + d_9)

		;- bloque[0] = par[0]*100 + par[1], 
		;- bloque[1] = par[2]*100 + par[3], 
		;- bloque[2] = par[3]
		pmaddwd xmm0, [mult_100_1] ; xmm0 = [bloque[0], bloque[1], bloque[2], 0, 0, 0, 0, 0]

		;multiplicamos bloque[0] por 10000 = bloque[0]'
		pmulld xmm0, [mult_10000_1] ;xmm0 = [bloque[0]', bloque[1], bloque[2], 0, 0, 0, 0, 0]
		
		;sumo bloque[0]' y bloque[1]
		phaddd xmm0, xmm0 ;xmm0 = [(bloque[0]' + bloque[1]), bloque[2], 0, 0, 0, 0, 0]

		;muevo los dijitos 8 y 9 a un qword en xmm1
		movdqa xmm1, xmm0
		psrlq xmm1, 32

		;uso pmuldq para multiplicar los 32 bits mas bajos de xmm0 por 100 (bloque[0]' + bloque[1])*100 y los guarda en un qword en 64 bits
		pmuludq xmm0, [mult_100_qword]

		;ya tengo las dos partes en qwords entonces las sumo
		paddq xmm0, xmm1

		;GUARDO EL VALOR
		movq [rdx + r8 * 8], xmm0
		inc r8
		

	.sigElemento:
	add r10, 10
	jmp .ciclo
	.finCiclo:



	ret
