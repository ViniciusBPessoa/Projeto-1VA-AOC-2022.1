# Projeto 1 VA Arquitetura e Organização de Computadores - 2022.1
# Alunos: Vinícius Bezerra, Irlan Farias, Apolo Albuquerque, joão vitor castro
# Descrição do arquivo: Código .asm da questão 1
# Substituir caracteres em uma string em MIPS Assembly

.data

mensagem1: .asciiz "Digite uma string: "
string: .space 100

mensagem2: .asciiz "Digite o caractere a ser substituído (C1): "
caractere1: .byte 0

mensagem3: .asciiz "Digite o caractere substituto (C2): "
caractere2: .byte 0

mensagem4: .asciiz "A string com as substituições: "

linebreak: .asciiz "\n"

.text
    
    la $a0, mensagem1 					#Carrega o endereço de 'mensagem1' em $a0
    jal imprime_string 					#Chama o procedimento imprime_string

    #i. Recebe uma string (string) do usuário
    
    li $v0, 8						#Chama a função ler string
    la $a0, string					#Carrega o endereço de 'string' em a0
    li $a1, 100						#Parâmetro da função ler string, quantidade máxima de bytes que serão lidos
    syscall						#Executa a função

    la $a0, mensagem2					#Carrega o endereço de 'mensagem2' em $a0
    jal imprime_string 					#Chama o procedimento imprime_string

    #ii. Recebe um char (caractere1) do usuário

    li $v0, 12						#Chama a função ler caractere
    syscall						#Executa a função	
    sb $v0, caractere1					#Guarda o caractere de 'caractere1' em $v0

    jal quebralinha     				#Chama o procedimento de quebra de linha (Em console)

    la $a0, mensagem3					#Carrega o endereço de 'mensagem3' em $a0
    jal imprime_string 					#Chama o procedimento imprime_string

    #iii. Recebe um char (caractere2) do usuário

    li $v0, 12						#Chama a função ler caractere
    syscall						#Executa a função	
    sb $v0, caractere2					#Guarda o caractere de 'caractere2' em $v0

    jal quebralinha     				#Chama o procedimento de quebra de linha (Em console)

    #iv. Substituir caractere 1 por caractere 2 na string
    #v. Imprime a nova string com os caracteres substituídos
    
    la $s0, string        				#Carrega o endereço de 'string' em $s0
    lb $s1, caractere1    				#Carrega o caractere de 'caractere1' em $s1
    lb $s2, caractere2    				#Carrega o caractere de 'caractere2' em $s2

    jal loop						#Chama o procedimento que vai realizar a troca de caracteres
    
le_caractere:
    li $v0, 12						#Chama a função ler caractere
    syscall						#Executa a função	
    sb $v0, caractere1					#Guarda o caractere de 'caractere1' em $v0

imprime_string:						#Recebe a string a ser lida em $a0
    li $v0, 4						#Chama a função imprimir string
    syscall						#Executa a função
    jr $ra						#Retorna pra quem chamou o procedimento

quebralinha:							
    li $v0, 4						#Chama a função imprimir string
    la $a0, linebreak					#Carrega o endereço de 'linebreak' em $a0
    syscall						#Executa a função
    jr $ra						#Retorna pra quem chamou o procedimento

loop:
    lb $t0, 0($s0)        				#Carrega o próximo caractere da string em $t0
    beq $t0, $0, fim      				#Se o caractere for nulo, encerra o loop
    bne $t0, $s1, next    				#Se o caractere não for igual ao caractere 1, ir para o próximo
    sb $s2, 0($s0)        				#Substitui o caractere 1 pelo caractere 2

next:
    addi $s0, $s0, 1      				#Avança para o próximo caractere
    j loop						#Chama o procedimento que vai continuar realizando a troca de caracteres

fim:
    la $a0, string					#Carrega o endereço 'string' em $a0
    jal imprime_string					#Chama o procedimento que vai imprimir a string

    li $v0, 10						#Chama a função sair
    syscall						#Executa a função
