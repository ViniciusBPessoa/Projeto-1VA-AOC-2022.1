# Projeto 1 VA Arquitetura e Organização de Computadores - 2022.1
# Alunos: Vinícius Bezerra, Irlan Farias, Apolo Albuquerque, joão vitor castro
# Descrição do arquivo: Código .asm da questão 4 letra b

.data
# Os tipos de dados abaixo foram usados apenas como teste.
# É sabido que os endereços de source e destination podem se interseccionar em determinado ponto ou até mesmo serem os mesmos.
# Mas isso não interfere no funcionamento do programa, basta testar com diferentes tipos.

	num: .word 2			# Quantidade de bits a serem copiados (para testar bastar colocar qualquer valor aqui)
	source: .asciiz "Apolo"		# Fonte de onde serão tirados os bits (.asciiz foi usado somente como teste, qualquer tipo de dado pode ser colocado aqui)
	destination: .space 10		# Bloco de memória destino para os bits copiados (pode colocar qualquer tamanho para o .space)
.text
main:
	la $a0, destination		# Lendo o endereço do bloco de memória destino
	la $a1, source			# Lendo o endereço do local de fonte dos bits a serem copiados
	lw $a2, num			# Lendo a quantidade de bits a serem copiadas
	
	add $t1, $0, $0			# Por segurança, atribuindo o valor 0 ao reg t1 que servirá como contador
	
	j memcpy			# Jump para a função

#Função solicitada na questão
memcpy:
	beq $t1, $a2, fim		# Caso o contador chegue ao valor atribuido em num, pulamos para o fim do programa
	lb $t0, 0($a1)			# Lê o byte no endereço base da source (a ser incrementado abaixo)
	sb $t0, 0($a0)			# Armazena o byte lido no endereço base de destination (a ser incrementado abaixo)
	addi $a1, $a1, 1		# Incrementa em 1 o endereço base da source para ir para ler o próximo byte
	addi $a0, $a0, 1		# Incrementa em 1 o endereço base de destination para escrever no próximo byte 
	addi $t1, $t1, 1		# Incrementa em 1 o contador
	j memcpy			# Jump para continuar o loop

# Função que termina o programa, como foi solicitado na questão que o reg v0 recebesse o parâmetro destination
# optei por não finalizar o programa via código de serviço, visto que o reg v0 é o mesmo usado nos syscall's
fim:
	la $v0, destination		# Salva o endereço do parâmetro destination no reg v0


	
