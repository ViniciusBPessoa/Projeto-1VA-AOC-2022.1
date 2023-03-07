# Projeto 1 VA Arquitetura e Organização de Computadores - 2022.1
# Alunos: Vinícius Bezerra, Irlan Farias, Apolo Albuquerque, joão vitor castro
# Descrição do arquivo: Código .asm da questão 4 letra e

# Os tamanos do .spaces usados aqui foram arbitrários, podem ser mudados para testes
# Os .asciiz foram usados aqui apenas para testes, também podem ser alterados
.data
	destination: .space 20			# Espaço reservado na memória para string destino (usando .space, garantimos que não será sobreposta)
	source: .space 20			# Espaço reservado na memória para string fonte (usando .space, garantimos que não será sobreposta)
	
	str_test_dest: .asciiz "Apolo "		# String destino para teste
	str_test_src: .asciiz "ama MIPS."	# String fonte para teste
.text
main:
	la $a0, str_test_dest			# Lendo o endereço da string destino de teste para copiá-la para o space reservado
	la $a1, destination			# Lendo o endereço de destino reservado
	jal copia_string			# Jump and link para a função que copia a string teste para o espaço reservado (teste)
	
	la $a0, str_test_src			# Lendo o endereço da string fonte de teste para copiá-la para o space reservado
	la $a1, source				# Lendo o endereço de fonte reservado
	jal copia_string			# Jump and link para a função que copia a string teste para o espaço reservado (teste)
	
	la $a0, destination			# Lendo o endereço de destino reservado
	la $a1, source				# Lendo o endereço de fonte reservado
	
	j acha_final				# Jump para função que encontra o final (\0) da string destino
	
strcat:
	lb $t0, 0($a1)				# Lê o byte no endereço base da fonte (a ser incrementado abaixo)
	beq $t0, $0, fim			# Caso seja 0 (chegou ao final), pular para a função que finaliza o programa
	sb $t0, 0($a0)				# Caso não seja, armazena o byte exatamente, onde foi encontrado na função anterior, no final da string destino
	addi $a1, $a1, 1			# Incrementa em 1 o endereço base da fonte para ler o próximo byte
	addi $a0, $a0, 1			# Incrementa em 1 o endereço base do destino para escrever no próximo byte
	j strcat				# Jump para continuar 

# Função que encontra o final (\0) da string destino, o objetivo aqui é saber onde começar a escrever o conteúdo da string fonte
acha_final:
	lb $t0, 0($a0)				# Lê o byte no endereço base do destino (a ser incrementado abaixo)
	beq $t0, $0, strcat			# Caso seja 0 (chegou ao final), pular para a função que concatena de fato
	addi $a0, $a0, 1			# Caso não seja, incrementa mais um no endereço base
	j acha_final				# Jump para continuar o loop
	
# Função que copia as strings de teste para os espaços reservados (feita somente para testar o programa)
copia_string:
	lb $t0, 0($a0)				# Lê o byte no endereço base da string (a ser incrementado abaixo)
	beq $t0, $0, fim_copia_string		# Caso seja 0 (chegou ao final), pular para a função que volta para main
	sb $t0, 0($a1)				# Caso não, armazena o byte no espaço reservado em memória para string
	addi $a0, $a0, 1			# Incrementa em 1 o endereço base da string para ler o próximo byte
	addi $a1, $a1, 1			# Incrementa em 1 o endereço base do espaço reservado para escrever no próximo byte
	j copia_string				# Jump para continuar o loop

# Função de auxílio de copia_string para voltar para onde foi linkado no jal
fim_copia_string:
	jr $ra					# O reg $ra salva o endereço de onde estavamos ao fazer o jal, aqui fazemos um jump register para lá

# Função que termina o programa, como foi solicitado na questão que o reg v0 recebesse o parâmetro destination
# optei por não finalizar o programa via código de serviço, visto que o reg v0 é o mesmo usado nos syscall's
fim:
	la $v0, destination			# Salva o endereço do parâmetro destination no reg v0
	
	
	
	
