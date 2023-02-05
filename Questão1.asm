# Receber uma string do usuário em MIPS Assembly

.data
	frase: .word 201 # numero maximo de bites para caracteres que o usuario podera digitar
	c1: .word 3
	c2: .word 3
.text

main:

    addi $v0, $0, 8 # soma(8 + 0) para iniciar o protocolo de impreção de valores no console
    la $a0, frase
    addi $a1, $0, 201
    la $s0, frase
    syscall # o sistema executa o que foi solicitado
    
    addi $v0, $0, 8 # soma(8 + 0) para iniciar o protocolo de impreção de valores no console
    la $a0, c1
    addi $a1, $0, 3
    la $s1, c1
    syscall # o sistema executa o que foi solicitado
    
    addi $v0, $0, 8 # soma(8 + 0) para iniciar o protocolo de impreção de valores no console
    la $a0, c2
    addi $a1, $0, 3
    la $s2, c2
    syscall # o sistema executa o que foi solicitado
    
    addi $v0, $0, 4 # soma(4 + 0) para iniciar o protocolo de impreção de valores no console
    la $a0, frase # adiciona em a0 o valor a ser impresso na tela
    syscall # o sistema executa o que foi solicitado
    
    addi $v0, $0, 4 # soma(4 + 0) para iniciar o protocolo de impreção de valores no console
    la $a0, c1 # adiciona em a0 o valor a ser impresso na tela
    syscall # o sistema executa o que foi solicitado
    
    addi $v0, $0, 4 # soma(4 + 0) para iniciar o protocolo de impreção de valores no console
    la $a0, c2 # adiciona em a0 o valor a ser impresso na tela
    syscall # o sistema executa o que foi solicitado
    
    # Encerrar o programa
    addi $v0, $0, 10
    syscall
