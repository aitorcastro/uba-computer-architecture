extern calloc
extern strncmp

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

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

global calcular_estadisticas

;void calcular_estadisticas(caso_t* arreglo_casos, int largo, uint32_t usuario_id)
calcular_estadisticas:
;-PROLOGO INI------
push rbp
mov rbp, rsp
sub rsp, 24
push r12
push r13
push r14
push r15
push rbx
;-PROLOGO FIN------

;guardo parametros
mov [rbp-8], rdi
mov r12, rdi
mov r13, rsi
mov r14d, edx

;guardo el resultado en memoria inicializado en cero
mov rdi, 1
mov rsi, ESTADISTICAS_SIZE
call calloc
mov rbx, rax

xor r15d, r15d

cmp r14d, 0
jne .usuario_loop

.total_loop:
    cmp r15d, r13d
    jge .fin

    mov r9, r15
    imul r9, CASO_SIZE
    lea r11, [r12 + r9]

    ; categoria = CLT
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET]
    cmp al, 'C'
    jne .total_chequeo_rbo
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 1]
    cmp al, 'L'
    jne .total_chequeo_rbo
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 2]
    cmp al, 'T'
    jne .total_chequeo_rbo
    inc byte [rbx + ESTADISTICAS_CLT_OFFSET]
    jmp .total_actualizo_estado

.total_chequeo_rbo:
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET]
    cmp al, 'R'
    jne .total_chequeo_ksc
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 1]
    cmp al, 'B'
    jne .total_chequeo_ksc
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 2]
    cmp al, 'O'
    jne .total_chequeo_ksc
    inc byte [rbx + ESTADISTICAS_RBO_OFFSET]
    jmp .total_actualizo_estado

.total_chequeo_ksc:
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET]
    cmp al, 'K'
    jne .total_chequeo_kdt
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 1]
    cmp al, 'S'
    jne .total_chequeo_kdt
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 2]
    cmp al, 'C'
    jne .total_chequeo_kdt
    inc byte [rbx + ESTADISTICAS_KSC_OFFSET]
    jmp .total_actualizo_estado

.total_chequeo_kdt:
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET]
    cmp al, 'K'
    jne .total_siguiente
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 1]
    cmp al, 'D'
    jne .total_siguiente
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 2]
    cmp al, 'T'
    jne .total_siguiente
    inc byte [rbx + ESTADISTICAS_KDT_OFFSET]

.total_actualizo_estado:
    movzx r8d, word [r11 + CASO_ESTADO_OFFSET]
    cmp r8d, 0
    jne .total_chequear_estado_1
    inc byte [rbx + ESTADISTICAS_ESTADO0_OFFSET]
    jmp .total_siguiente

.total_chequear_estado_1:
    cmp r8d, 1
    jne .total_chequear_estado_2
    inc byte [rbx + ESTADISTICAS_ESTADO1_OFFSET]
    jmp .total_siguiente

.total_chequear_estado_2:
    cmp r8d, 2
    jne .total_siguiente
    inc byte [rbx + ESTADISTICAS_ESTADO2_OFFSET]

.total_siguiente:
    inc r15d
    jmp .total_loop

.usuario_loop:
    cmp r15d, r13d
    jge .fin

    mov r9, r15
    imul r9, CASO_SIZE
    lea r11, [r12 + r9]

    mov r9, [r11 + CASO_USUARIO_OFFSET]
    mov r9d, [r9 + USUARIO_ID_OFFSET]

    cmp r9d, r14d
    jne .usuario_siguiente

    ; categoria = CLT
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET]
    cmp al, 'C'
    jne .usuario_chequeo_rbo
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 1]
    cmp al, 'L'
    jne .usuario_chequeo_rbo
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 2]
    cmp al, 'T'
    jne .usuario_chequeo_rbo
    inc byte [rbx + ESTADISTICAS_CLT_OFFSET]
    jmp .usuario_actualizo_estado

.usuario_chequeo_rbo:
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET]
    cmp al, 'R'
    jne .usuario_chequeo_ksc
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 1]
    cmp al, 'B'
    jne .usuario_chequeo_ksc
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 2]
    cmp al, 'O'
    jne .usuario_chequeo_ksc
    inc byte [rbx + ESTADISTICAS_RBO_OFFSET]
    jmp .usuario_actualizo_estado

.usuario_chequeo_ksc:
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET]
    cmp al, 'K'
    jne .usuario_chequeo_kdt
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 1]
    cmp al, 'S'
    jne .usuario_chequeo_kdt
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 2]
    cmp al, 'C'
    jne .usuario_chequeo_kdt
    inc byte [rbx + ESTADISTICAS_KSC_OFFSET]
    jmp .usuario_actualizo_estado

.usuario_chequeo_kdt:
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET]
    cmp al, 'K'
    jne .usuario_siguiente
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 1]
    cmp al, 'D'
    jne .usuario_siguiente
    mov al, byte [r11 + CASO_CATEGORIA_OFFSET + 2]
    cmp al, 'T'
    jne .usuario_siguiente
    inc byte [rbx + ESTADISTICAS_KDT_OFFSET]

.usuario_actualizo_estado:
    movzx r8d, word [r11 + CASO_ESTADO_OFFSET]
    cmp r8d, 0
    jne .usuario_chequear_estado_1
    inc byte [rbx + ESTADISTICAS_ESTADO0_OFFSET]
    jmp .usuario_siguiente

.usuario_chequear_estado_1:
    cmp r8d, 1
    jne .usuario_chequear_estado_2
    inc byte [rbx + ESTADISTICAS_ESTADO1_OFFSET]
    jmp .usuario_siguiente

.usuario_chequear_estado_2:
    cmp r8d, 2
    jne .usuario_siguiente
    inc byte [rbx + ESTADISTICAS_ESTADO2_OFFSET]

.usuario_siguiente:
    inc r15d
    jmp .usuario_loop

.fin:
    mov rax, rbx

;-EPILOGO INI------
pop rbx
pop r15
pop r14
pop r13
pop r12
add rsp, 24
pop rbp
ret