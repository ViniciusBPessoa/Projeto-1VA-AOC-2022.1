# Substituir caracteres em uma string em MIPS Assembly

.data
mensagem1: .asciiz "Digite uma string: "
string: .space 100
mensagem2: .asciiz "Digite o caractere a ser substituído (C1): "
caractere1: .byte 0
mensagem3: .asciiz "Digite o caractere substituto (C2): "
caractere2: .byte 0

.text
.globl main
main:
    # Imprimir a mensagem solicitando a string
    li $v0, 4
    la $a0, mensagem1
    syscall

    # Receber a string do usuário
    li $v0, 8
    la $a0, string
    li $a1, 100
    syscall

    # Imprimir a mensagem solicitando o caractere 1
    li $v0, 4
    la $a0, mensagem2
    syscall

    # Receber o caractere 1 do usuário
    li $v0, 12
    syscall
    sb $v0, caractere1

    # Imprimir a mensagem solicitando o caractere 2
    li $v0, 4
    la $a0, mensagem3
    syscall

    # Receber o caractere 2 do usuário
    li $v0, 12
    syscall
    sb $v0, caractere2

    # Substituir caractere 1 por caractere 2 na string
    la $s0, string        # Endereço da string
    lb $s1, caractere1    # Caractere 1
    lb $s2, caractere2    # Caractere 2

loop:
    lb $t0, 0($s0)        # Carregar o próximo caractere da string
    beq $t0, $0, fim      # Se o caractere for nulo, encerrar o loop
    bne $t0, $s1, next    # Se o caractere não for igual ao caractere 1, ir para o próximo
    sb $s2, 0($s0)        # Substituir o caractere 1 pelo caractere 2

next:
    addi $s0, $s0, 1      # Avançar para o próximo caractere
    j loop

fim:
    # Imprimir a nova string
    li $v0, 4
    la $a0, string
    syscall

    # Encerrar o programa
    li $v0, 10
    syscall
