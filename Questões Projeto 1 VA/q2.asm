# Projeto 1 VA Arquitetura e Organização de Computadores - 2022.1
# Alunos: Vinícius Bezerra, Irlan Farias, Apolo Albuquerque, joão vitor castro
# Descrição do arquivo: Código .asm da questão 2

.data
	string: .space 100 		# Constante para armazenar a string inserida pelo usuário
	quebra_linha: .ascii "\n" 	# Constante que representa o valor de quebra de linha (caso o usuário dê enter)
.text
main:
	li $v0, 8 		# (8) Código de serviço para ler strings no console
    	la $a0, string 		# Indicando o endereço onde a string lida será armazenada
    	li $a1, 100 		# Reservando espaço de 99 caracteres para string a ser inserida pelo usuário
    	lw $a2, quebra_linha	# Armazenando o valor de "\n" (enter)
    	syscall			# Chamada ao console (sistema)
    	
    	li $v0, 0 		# Limpa o valor que estava em $v0 para que o registrador possa ser utilizado na função len
    	
    	j len			# Jump (pula) para a função que conta o tamanho da string

#Função que conta o tamanho da string 	
len:
	lb $t0, 0($a0)      	# Lendo o valor "cabeça" da string 
    	beq $t0, $a2, fim	# Caso o usuário tenha dado enter ao terminar de digitar, o último valor da string será o "\n"
    	beq $t0, $0, fim	# Caso o usuário termine de usar todos os 99 caracteres disponíveis, o último valor será o "\0"
    	addi $v0, $v0, 1	# Caso passe dos dois branch if equal, conta-se mais um para o tamanho da string
    	addi $a0, $a0, 1	# Adiciona mais um ao endereço base da string para ir para o próximo caractere
    	j len			# Jump para continuar o loop da função
    	
#Função que é acionada quando termina-se de ler a string
fim:
	add $s0, $v0, $0 	# (Boa prática) Salvar o retorno de uma função em um registrador seguro
	addi $v0, $0, 1		# (1) Código de serviço para printar inteiros no console
	add $a0, $s0, $0	# Adiciona o valor a ser printado
	syscall			# Chamada ao console (sistema)
	
	addi $v0, $0, 10	# (10) Código de serviço para encerrar o programa
	syscall			# Chamada ao console (sistema)
