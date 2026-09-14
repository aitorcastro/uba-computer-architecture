extern strncmp
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

global resolver_automaticamente

;void resolver_automaticamente(funcionCierraCasos* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo)
;--PARAMETROS--
;- rdi = funcion (puntero)
;- rsi = arreglo casos (direccion de inicio)
;- rdx = arreglo casos a revisar (direccion de inicio)
;- ecx = largo
;---------------
resolver_automaticamente:
;-PROLOGO INI------
;--Alinear la pila y guardar rbp
push rbp
mov rbp, rsp

;--Reservar lugar en la pila
sub rsp, 24

;--Preservar registros no-volatiles
push r12
push r13
push r14
push r15
push rbx
;-PROLOGO FIN------

;-CUERPO------
cmp ecx, 0
je .terminar
;GUARDO PARAMETROS
;no tengo lugar para todos, guardo los que escribo much en registros y los de solo lectura en la pila
mov r12, rdi ;r12 = funcion
mov qword [rbp-8], rsi ;[rbp-8] = direccion inicio casos
mov qword [rbp-16], rdx ;[rbp-16] = direccion inciio casos a revisar
mov r13d, ecx ;r13d = largo

;MANTENGO UN INDICE DE CASOS A REVISAR
xor r14, r14 ;r14 = indiceCasosARevisar

;RECORRO EL ARREGLO DE CASOS
xor r15, r15 ;i = 0
.ciclo:
    ;BUSCO DIRECCION DEL CASO ACTUAL (inicio casos + i * caso_size)
    mov r8, [rbp-8] ;r8 = inicio casos
    mov r9, r15
    imul r9, CASO_SIZE ;r9 = i * caso_size
    lea rbx, [r8 + r9] ;rbx = pCasoActual

    ;BUSCO NIVEL DEL USUARIO DEL CASO ACTUAL
    mov r8, [rbx + CASO_USUARIO_OFFSET] ;r8d = pUsuarioActual
    mov r8d, [r8 + USUARIO_NIVEL_OFFSET] ;r8d = nivelUduarioActual
    ;CASO NIVEL = 0
    cmp r8d, 0
    jne .casoNivel1
        ;AGREGO EL CASO A CASOS A REVISAR AGREGO A CASOS A REVISAR
        mov r9, [rbp-16] ;r9 = inicio casos a revisar
        mov r10, r14
        imul r10, CASO_SIZE ;r10 = indiceCAR * casosize
        mov rax, qword[rbx]

        ;copio la primer mitad del caso
        mov qword[r9 + r10], rax
        mov rax, qword[rbx+8]
        add r10, 8

        ;copio la segunda mitad del caso
        mov qword [r9 + r10], rax

        ;ACTUALIZO INDICE
        inc r14

        ;SIGO RECORRIENDO
        jmp .sigElemento

    ;CASO NIVEL = 1 ó 2
    .casoNivel1:
    cmp r8d, 1
    je .llamoALaFuncion
    cmp r8d, 2
    jne .sigElemento
        ;LLAMO A LA FUNCION
        .llamoALaFuncion:
        mov rdi, rbx
        call r12; rax = resFuncion

        ;CASO RES ES 0
        cmp rax, 0
        jne .casoRes1
            ;BUSCO LA CATEGORIA
            lea rdi, [rbx + CASO_CATEGORIA_OFFSET] ;rdi = categoria

            ;SI ES IGUAL A "CLT"
            mov dword[rbp-24], 'CLT' 
            lea rsi, [rbp-24]
            mov rdx, 4
            call strncmp ;rax = 0 si son iguales 
            cmp rax, 0
            jne .chequearRBO
                ;ESTADO = 2
                mov word[rbx + CASO_ESTADO_OFFSET], 2
            .chequearRBO:
            ;SI NO, SI ESIGUAL A "RBO"
            mov dword[rbp-24], 'RBO' 
            lea rsi, [rbp-24]
            mov rdx, 4
            call strncmp ;rax = 0 si son iguales 
            cmp rax, 0
            jne .agregarACasosPendientes
                ;ESTADO = 2
                mov word[rbx + CASO_ESTADO_OFFSET], 2

            .agregarACasosPendientes:
            ;SI NO
                ;LO AGREGO A CASOS A REVISAR
                mov r9, [rbp-16] ;r9 = inicio casos a revisar
                mov r10, r14
                imul r10, CASO_SIZE ;r10 = indiceCAR * casosize
                mov rax, qword[rbx]

                ;copio la primer mitad del caso
                mov qword[r9 + r10], rax
                mov rax, qword[rbx+8]
                add r10, 8

                ;copio la segunda mitad del caso
                mov qword [r9 + r10], rax

                ;ACTUALIZO INDICE
                inc r14

                ;SIGO RECORRIENDO
                jmp .sigElemento

        ;CASO RES ES 1
        .casoRes1:
        cmp rax, 1
        jne .sigElemento
            mov word[rbx + CASO_ESTADO_OFFSET], 1

.sigElemento:
inc r15 ;i++
;i >= largo?
cmp r15, r13
jge .terminar
jmp .ciclo

.terminar:
;-EPILOGO INI------
;-restaurar registros no-volatiles
pop rbx
pop r15
pop r14
pop r13
pop r12
;-libarar lugar de la pila
add rsp, 24
;-restaurar rbp
pop rbp
    ret
