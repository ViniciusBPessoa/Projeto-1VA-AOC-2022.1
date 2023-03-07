# Projeto 1 VA Arquitetura e Organização de Computadores - 2022.1
# Alunos: Vinícius Bezerra, Irlan Farias, Apolo Albuquerque, joão vitor castro
# Descrição do arquivo: Código .asm da questão 4 letra d

.data

mensagem1: .asciiz "Digite a str1: "
str1: .space 100

mensagem2: .asciiz "Digite a str2: "
str2: .space 100

mensagem3: .asciiz "Digite o número máximo de caracteres a serem comparados: "

linebreak: .asciiz "\n"

.text

main:

    la $a0, mensagem1 					#Carrega o endereço de 'mensagem1' em $a0
    jal imprime_string 					#Chama o procedimento imprime_string
    li $v0, 8						#Chama a função ler string
    la $a0, str1					#Carrega o endereço de 'str1' em a0
    li $a1, 100						#Parâmetro da função ler string, quantidade máxima de bytes que serão lidos
    syscall						#Executa a função
    move $t0, $a0					#Copia o valor de $t0 para $a0
    
    la $a0, mensagem2				        #Carrega o endereço de 'mensagem1' em $a0
    jal imprime_string 					#Chama o procedimento imprime_string
    li $v0, 8						#Chama a função ler string
    la $a0, str2					#Carrega o endereço de 'str2' em a0
    li $a1, 100						#Parâmetro da função ler string, quantidade máxima de bytes que serão lidos
    syscall						#Executa a função
    move $t1, $a0
    
    la $a0, mensagem3 					#Carrega o endereço de 'mensagem1' em $a0
    jal imprime_string 					#Chama o procedimento imprime_string
    li $v0, 5						#Chama função de ler inteiro
    syscall						#Executa 
    
    move $a0, $t0					#Copia o valor de $t0 para $a0
    move $a1, $t1					#Copia o valor de $t1 para $a1
    move $a3, $v0					#Copia o valor de $v0 para $a3
    
    jal strncmp						#Chama o procedimento strncmp
    
    move $s7, $v1					#Copia o valor de $v1 para $s7
    
    jal sair						#Chama o procedimento sair
    
strncmp:
    li $t0, 0 						#Inicializa contador
    li $t1, 0 						#Inicializa index de str1
    li $t2, 0 						#Inicializa index de str2
    li $t3, 0 						#Inicizaliza a comparação de resultado
    j loop						#Chama o procedimento loop

loop:
    lb $t3, str1($t1) 					#Carrega caractere de str1
    lb $t4, str2($t2) 					#Carrega caractere de str2
    beq $t3, $t4, next 					#Caso os caracteres de str1 e str2 forem iguais, chame procedimento next
    bgt $t3, $t4, fim 					#Caso o caracter de str1 seja maior que o caracter str2, chame o procedimento fim
    j fim 						#Chama procedimento fim

next:
    addi $t0, $t0 ,1 					#Adiciona 1 a $t0 (contador)
    addi $t1, $t1 ,1 					#Adiciona 1 a $t1 (index de str1)
    addi $t2, $t2 ,1 					#Adiciona 1 a $t2 (index de str2)
    blt $t0, $a3, loop 					#Caso $t1 for menor que $t2 (contador menor que número n dado pelo usuário, chame procedimento loop


fim:
    sub $v1, $t3, $t4 					#Subtrai $t3 a $t4 e guarda em $v1
    jr $ra 						#Retorna pra quem chamou o procedimento
    
imprime_string:						#Recebe a string a ser lida em $a0
    li $v0, 4						#Chama a função imprimir string
    syscall						#Executa a função
    jr $ra						#Retorna pra quem chamou o procedimento

sair:							
    li $v0, 10						#Chama a função encerrar
    syscall						#Executa a função
