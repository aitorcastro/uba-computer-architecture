extern malloc
extern contar_casos_por_nivel
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0
USUARIO_NIVEL_OFFSET EQU 4
USUARIO_SIZE EQU 8

CASO_CATEGORIA_OFFSET EQU 0
CASO_ESTADO_OFFSET EQU 4
CASO_USUARIO_OFFSET EQU 8
CASO_SIZE EQU 16

SEGMENTACION_CASOS0_OFFSET EQU 0
SEGMENTACION_CASOS1_OFFSET EQU 8
SEGMENTACION_CASOS2_OFFSET EQU 16
SEGMENTACION_SIZE EQU 24

ESTADISTICAS_CLT_OFFSET EQU 0
ESTADISTICAS_RBO_OFFSET EQU 1
ESTADISTICAS_KSC_OFFSET EQU 2
ESTADISTICAS_KDT_OFFSET EQU 3
ESTADISTICAS_ESTADO0_OFFSET EQU 4
ESTADISTICAS_ESTADO1_OFFSET EQU 5
ESTADISTICAS_ESTADO2_OFFSET EQU 6
ESTADISTICAS_SIZE EQU 7

;segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo)
global segmentar_casos
;--PARAMETROS--
;- rdi = arreglo
;- edi = largo
segmentar_casos:
;--PROLOGO INI--
push rbp
mov rbp, rsp

;hago lugar en la pila
sub rsp, 32

;preservo registros no-volatiles
push r12
push r13
push r14
push r15 ;para alinear la pila
;--PROLOGO FIN--

;--CUERPO--
mov r12, rdi ;r12 = arreglo
mov r13d, esi ;r13 = largo

;CUENTO CCASOS POR NIVEL
mov rdi, r12
mov esi, r13d
mov r8, 0
mov dword [rbp-16], r8d
mov dword  [rbp-12], r8d
mov dword  [rbp-8], r8d
lea rdx, [rbp-16] ;contadores 32 bits
call contar_casos_por_nivel 
;[rbp-16] = contadores[0] 
;[rbp-12] = contadores[1]
;[rbp-8] = contadores[2]

;CREO RESULTADO 
mov rdi, SEGMENTACION_SIZE
call malloc;rax = rpuntero a resultado
mov r14, rax ;r14 = resultado

;INICIALIZO ARREGLOS DE SEGMENTACION
;---NIVEL 0---
;si hay al menos 1 inicializo un array si no null
    mov rax, 0
    mov edi, dword [rbp-16] ;rdi = contadores[0]
    cmp rdi, 0
    je .asignarN0 ;si no hay nada, salto y pongo null (rax ya es 0)

    ;si hay elementos aloco memoria para el arreglo
    imul rdi, CASO_SIZE ;rdi = contadores[0] * sizeof(caso_t)
    call malloc ;rax = puntero al arreglo casosN0

    .asignarN0:
    ;asigno a resultado el arrreglo casosN0
    mov qword [r14 + SEGMENTACION_CASOS0_OFFSET], rax

;---NIVEL 1---
;si hay al menos 1 inicializo un array si no null
    mov rax, 0
    mov edi, dword [rbp-12] ;rdi = contadores[1]
    cmp rdi, 0
    je .asignarN1 ;si no hay nada, salto y pongo null (rax ya es 0)

    ;si hay elementos aloco memoria para el arreglo
    imul rdi, CASO_SIZE ;rdi = contadores[1] * sizeof(caso_t)
    call malloc ;rax = puntero al arreglo casosN0

    .asignarN1:
    ;asigno a resultado el arrreglo casosN2
    mov qword [r14 + SEGMENTACION_CASOS1_OFFSET], rax

;---NIVEL 2---
;si hay al menos 1 inicializo un array si no null
    mov rax, 0
    mov edi, dword [rbp-8] ;rdi = contadores[2]
    cmp rdi, 0
    je .asignarN2 ;si no hay nada, salto y pongo null (rax ya es 0)

    ;si hay elementos aloco memoria para el arreglo
    imul rdi, CASO_SIZE ;rdi = contadores[2] * sizeof(caso_t)
    call malloc ;rax = puntero al arreglo casosN0

    .asignarN2:
    ;asigno a resultado el arrreglo casosN2
    mov qword [r14 + SEGMENTACION_CASOS2_OFFSET], rax

;MANTENGO UN ARRAY DE POSICIONES
;reemplazo el de contdores que no uso mas
;[rbp-16] = tamArrays[0] 
;[rbp-12] = tamArrays[1]
;[rbp-8] = tamArrays[2]
mov r8, 0
mov dword [rbp-16], r8d
mov dword  [rbp-12], r8d
mov dword  [rbp-8], r8d

;RECORRO EL ARREGLO
    cmp r13, 0
    je .terminar
    xor r15, r15 ;i = 0
    .ciclo:
        ;agarro direccion del caso actual [r12 + r15 * casoSize]
        mov r9, r15
        imul r9, CASO_SIZE
        lea r9, [r12 + r9] ;r9 = direccion caso actual

        ;agarro direccion del usuario actual [dir casoActual + ofset usuario]
        mov r8, [r9 + CASO_USUARIO_OFFSET]

        ;agarro el nivel del usuario actual [dir usuario actual + ofset nivel]
        mov r8d, dword [r8 + USUARIO_NIVEL_OFFSET] ;r8 = nivel

        ;----SWITCH(NIVEL)----
        ;r8 = nivel
        ;r9 = dir Caso Actual
            ;----CASO 0----
                cmp r8, 0
                jne .case1

                ;cargo el caso actual en el array de nivel 0 del resultado
                mov r10d, [rbp-16] ;r10 = tamArrays[0] 
                ;r11 = direccion de donde guardar el caso
                imul r10, CASO_SIZE
                mov r11, [r14 + SEGMENTACION_CASOS0_OFFSET]
                lea r11, [r11 + r10]

                ; copia 16 bytes = 2 qwords
                mov rax, [r9]
                mov [r11], rax
                mov rax, [r9 + 8]
                mov [r11 + 8], rax
                inc dword [rbp-16]

            ;----CASO 1----
                .case1:
                cmp r8, 1
                jne .case2

                ;cargo el caso actual en el array de nivel 1 del resultado
                mov r10d, [rbp-12] ;r10 = tamArrays[1] 
                ;r11 = direccion de donde guardar el caso
                imul r10, CASO_SIZE
                mov r11, [r14 + SEGMENTACION_CASOS1_OFFSET]
                lea r11, [r11 + r10]

                ; copia 16 bytes = 2 qwords
                mov rax, [r9]
                mov [r11], rax
                mov rax, [r9 + 8]
                mov [r11 + 8], rax
                inc dword [rbp-12]

            ;----CASO 1----
                .case2:
                cmp r8, 2
                jne .sigElemento

                ;cargo el caso actual en el array de nivel 2 del resultado
                mov r10d, [rbp-8] ;r10 = tamArrays[2] 
                ;r11 = direccion de donde guardar el caso
                imul r10, CASO_SIZE
                mov r11, [r14 + SEGMENTACION_CASOS2_OFFSET]
                lea r11, [r11 + r10]

                ; copia 16 bytes = 2 qwords
                mov rax, [r9]
                mov [r11], rax
                mov rax, [r9 + 8]
                mov [r11 + 8], rax
                inc dword [rbp-8]

    .sigElemento:
    inc r15
    cmp r15, r13
    jge .terminar
    jmp .ciclo

.terminar:
mov rax, r14
;--EPILOGO INI--
pop r15
pop r14
pop r13
pop r12
add rsp, 32
pop rbp
;--EPILOGO FIN--
ret

;--guia de registros--
;- r12 = arreglo
;- r13 = largo
;- [rbp-8 - rbp-16] = contadores / tamArrays
;- r14 = resultado
;[rbp-16] = contadores[0]
;[rbp-12] = contadores[1]
;[rbp-8] = contadores[2]