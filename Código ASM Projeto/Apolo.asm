.eqv rcvr_ctrl 0xffff0000
.eqv rcvr_data 0xffff0004
.eqv trsmttr_ctrl 0xffff0008
.eqv trsmttr_data 0xffff000c

.data
	str_padrao: .asciiz "VIA-shell>> "	# String padrão a ser exibida no MMIO
	barra_n: .byte 10					# Valor equivalente na tabela ASCII da quebra de linha (\n)
	terminal_cmd: .space 100			# Espaço/Variável para armazenar o que é digitado pelo usuário no MMIO
	
	str_cmd_ad_m: .asciiz "ad_morador-"		# String de comando para adicionar morador
	str_cmd_rm_m: .asciiz "rm_morador-"		# String de comando para remover morador
	str_cmd_ad_a: .asciiz "ad_auto-"		# String de comando para adicionar automovel
	str_cmd_rm_a: .asciiz "rm_auto-"		# String de comando para remover automovel
	str_cmd_lp_ap: .asciiz "limpar_ap-"		# String de comando para limpar apartamento
	str_cmd_if_ap: .asciiz "info_ap-"		# String de comando para informações de AP especifico
	str_cmd_if_g: .asciiz "info_geral"		# String de comando para informações dos APs em geral
	str_cmd_s: .asciiz "salvar"				# String de comando para salvar as infos num arquivo
	str_cmd_r: .asciiz "recarregar"			# String de comando para recarregar as infos do arquivo
	str_cmd_f: .asciiz "formatar"			# String de comando para formatar o arquivo
	msg_c_v: .asciiz "Comando Valido"		# String usada apenas para testes de comandos válidos digitados no MMIO
	msg_c_i: .asciiz "Comando Invalido"		# String usada apenas para testes de comandos inválidos digitados no MMIO

.text
main:
	la $s0, msg_c_v					# Lê o endereço da string teste de comando válido
	la $s1, msg_c_i					# Lê o endereço da string teste de comando inválido
	la $a1, str_padrao				# Lê o endereço da string padrão a ser exibida no MMIO
	jal shell_str_loop				# Pula para a função que escreve a string padrão no MMIO e volta
	la $a1, terminal_cmd			# Lê o endereço da variável que armazena o que foi digitado no MMIO
	j rcvr_loop						# Pula para o loop que aguarda as inserções no MMIO
	
# Função que compara strings para ver se são iguais
compara_str:
	lb $t0, 0($a0)					# Lê o byte da string 1
	lb $t1, 0($a1)					# Lê o byte da string 2
	bne $t0, $t1, str_diferente		# Caso sejam diferentes, pula pra função que lida com isso
	beq $t0, $0, filtro_str0		# Caso a string 1 acabe, vai para o filtro que verifica se a string 2 acabou também.
	beq $t1, $0, filtro_str1		# Caso a string 2 acabe, vai para o filtro que verifica se a string 1 acabou também.
	addi $a0, $a0, 1				# Adiciona 1 ao endereço da string 1 para ir para o próximo caractere
	addi $a1, $a1, 1				# Adiciona 1 ao endereço da string 2 para ir para o próximo caractere
	j compara_str					# Jump para continuar o loop

# Função que trata as strings caso sejam diferentes
str_diferente:
	addi $v0, $0, 1					# Retorna 1 em v0
	jr $ra							# Volta a execução do topo da pilha
	
# Função que trata as strings caso sejam iguais
str_igual:
	move $v0, $0					# Retorna 0 em v0
	jr $ra							# Volta a execução do topo da pilha

# Filtro da string 1
filtro_str0:
	beq $t1, $0, str_igual			# Caso a string 2 tenha terminado também é porque são iguais, daí vai para função correspondente
	j str_diferente					# Caso não, vai para função de strings diferentes

# Filtro da string 2	
filtro_str1:
	beq $t0, $0, str_igual			# Caso a string 1 tenha terminado também é porque são iguais, daí vai para função correspondente
	j str_diferente					# Caso não, vai para função de strings diferentes
	
# Função que escreve a string padrão do shell a ser exibinda no MMIO toda vez há quebra de linha (e na primeira execução também)
shell_str_loop:
	lw $t0, trsmttr_ctrl		# Lê o conteudo escrito no transmitter control no reg t0		
    andi $t1, $t0, 1        	# Faz a operação AND entre o valor contido no reg t0 e 1 a fim de isolar o último bit (bit "pronto")       		
    beq $t1, $zero, shell_str_loop		# Caso seja 0, o transmissor não está pronto para receber valores: continua o loop
	lb $t2, 0($a1)						# Carrega um byte da string padrão a ser impressa no MMIO
	beq $t2, $zero, go_back				# Caso seja 0: a string terminou, vai para função que volta pra main
	sb $t2, trsmttr_data				# Caso não seja: escreve o byte no transmitter do MMIO
	addi $a1, $a1, 1					# Soma 1 ao endereço da string padrão para ir para o próximo byte a ser escrito
	j shell_str_loop					# Jump para continuar o loop
	
# Função auxiliar para voltar pra main (no momento só serve pra isso)
go_back:
	jr $ra						# Pula para o topo da pilha de execução
	
# Função que faz o loop do receiver (recebendo o que foi digitado pelo usuário no MMIO)
rcvr_loop:	
    lw $t0, rcvr_ctrl				# Lê o conteudo escrito no receiver control no reg t0			          
    andi $t1, $t0, 1            	# Faz a operação AND entre o valor contido no reg t0 e 1 a fim de isolar o último bit (bit "pronto")	
    beq $t1, $zero, rcvr_loop		# Caso seja 0, não está pronto: o caractere ainda não foi completamente lido no Receiver Data
    lb $a0, rcvr_data				# Caso seja 1, está pronto: aqui o caractere escrito no terminal é lido no Receiver Data
    sb $a0, 0($a1)					# Guarda o caractere lido no espaço de memória "terminal_cmd" que será usado para verificar se o comando escrito é aceito
    lb $t0, barra_n					# Lê o valor do "\n" (10 na tabela ASCII) para saber se o usuário deu um "enter"
    beq $a0, $t0, verifica_cmds		# Caso o usuário dê "enter" vai para função que verifica se o comando é válido
    j trsmttr_loop					# Pula para função que faz o loop do transmitter (para escrever no MMIO o que foi digitado)

# Função que quebra a linha no display do MMIO
quebra_linha:
	lw $t0, trsmttr_ctrl			# Lê o conteudo escrito no transmitter control no reg t0		
    andi $t1, $t0, 1               	# Faz a operação AND entre o valor contido no reg t0 e 1 a fim de isolar o último bit (bit "pronto") 
    beq $t1, $zero, quebra_linha    # Caso seja 0, o transmissor não está pronto para receber valores: continua o loop
	lb $t0, barra_n					# Lê o valor do "\n" (10 na tabela ASCII) para inserir no display do MMIO
	sb $t0, trsmttr_data			# Escreve o "\n" ("enter") no display do MMIO
	jr $ra							# Pula para o topo da pilha de execução

# Função que faz o loop do transmitter (para escrever no MMIO o que foi digitado)
trsmttr_loop:
    lw $t0, trsmttr_ctrl			# Lê o conteudo escrito no transmitter control no reg t0		
    andi $t1, $t0, 1               	# Faz a operação AND entre o valor contido no reg t0 e 1 a fim de isolar o último bit (bit "pronto")	
    beq $t1, $zero, trsmttr_loop	# Caso seja 0, o transmissor não está pronto para receber valores: continua o loop
    sb $a0, trsmttr_data			# Escreve o caractere no display do MMIO
    addi $a1, $a1, 1				# Soma 1 ao endereço do espaço de memória "terminal_cmd" (usado para guardar o que usuário digitou)
    j rcvr_loop						# Pula para função que faz o loop do receiver (para ler o próximo caractere que foi digitado)
    
# Função que verifica se o comando digitado é válido    
verifica_cmds:
	jal quebra_linha				# Jump  para função que quebra linha no display do MMIO
	
	sb $0, 0($a1)					# Subistitui o ultimo caractere digitado no MMIO ("\n") por 0, afim de determinar o fim do comando
	
	la $a0, str_cmd_ad_m			# Lê o endereço da string de comando para adicionar morador
	la $a1, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário
	jal compara_str					# Pula para função que compara strings e volta
	beq $v0, $0, cmd_ad_m			# Caso $v0 volte da comparação com valor 0 significa que o comando digitado é o de adicionar morador, dai pula para função responsável
	
	la $a0, str_cmd_rm_m			# Lê o endereço da string de comando para remover morador
	la $a1, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário
	jal compara_str					# Pula para função que compara strings e volta
	beq $v0, $0, cmd_rm_m			# Caso $v0 volte da comparação com valor 0 significa que o comando digitado é o de remover morador, dai pula para função responsável
	
	la $a0, str_cmd_ad_a			# Lê o endereço da string de comando para adicionar automovel
	la $a1, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário			
	jal compara_str					# Pula para função que compara strings e volta
	beq $v0, $0, cmd_ad_a			# Caso $v0 volte da comparação com valor 0 significa que o comando digitado é o de adicionar automovel, dai pula para função responsável
	
	la $a0, str_cmd_rm_a			# Lê o endereço da string de comando para remover automovel
	la $a1, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário			
	jal compara_str					# Pula para função que compara strings e volta
	beq $v0, $0, cmd_rm_a			# Caso $v0 volte da comparação com valor 0 significa que o comando digitado é o de remover automovel, dai pula para função responsável
	
	la $a0, str_cmd_lp_ap			# Lê o endereço da string de comando para limpar apartamento
	la $a1, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário			
	jal compara_str					# Pula para função que compara strings e volta
	beq $v0, $0, cmd_lp_ap			# Caso $v0 volte da comparação com valor 0 significa que o comando digitado é o de limpar apartamento, dai pula para função responsável
	
	la $a0, str_cmd_if_ap			# Lê o endereço da string de comando para informações de AP especifico
	la $a1, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário			
	jal compara_str					# Pula para função que compara strings e volta
	beq $v0, $0, cmd_if_ap			# Caso $v0 volte da comparação com valor 0 significa que o comando digitado é o de informações de AP especifico, dai pula para função responsável
	
	la $a0, str_cmd_if_g			# Lê o endereço da string de comando para informações dos APs em geral
	la $a1, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário			
	jal compara_str					# Pula para função que compara strings e volta
	beq $v0, $0, cmd_if_g			# Caso $v0 volte da comparação com valor 0 significa que o comando digitado é o de informações dos APs em geral, dai pula para função responsável
	
	la $a0, str_cmd_s				# Lê o endereço da string de comando para salvar as infos num arquivo
	la $a1, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário			
	jal compara_str					# Pula para função que compara strings e volta
	beq $v0, $0, cmd_s				# Caso $v0 volte da comparação com valor 0 significa que o comando digitado é o de salvar as infos num arquivo, dai pula para função responsável
	
	la $a0, str_cmd_r				# Lê o endereço da string de comando para recarregar as infos do arquivo
	la $a1, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário			
	jal compara_str					# Pula para função que compara strings e volta
	beq $v0, $0, cmd_r				# Caso $v0 volte da comparação com valor 0 significa que o comando digitado é o de recarregar as infos do arquivo, dai pula para função responsável
	
	la $a0, str_cmd_f				# Lê o endereço da string de comando para formatar o arquivo
	la $a1, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário			
	jal compara_str					# Pula para função que compara strings e volta
	beq $v0, $0, cmd_f				# Caso $v0 volte da comparação com valor 0 significa que o comando digitado é o de formatar o arquivo, dai pula para função responsável
	
	j cmd_invalido					# Caso não entre em nenhum dos branchs significa que o comando digitado é inválido, daí pula para função que escreve "Comando Inválido" no display MMIO
	
# Função de adicionar morador	
cmd_ad_m:
	la $a0, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário
	addi $a0, $a0, 11				# Soma 11 ao endereço afim de ir para onde começa o numero do AP 
	addi $a1, $a0, 3				# Soma mais 2 aos 11 somados afim de ir para onde começa o nome do morador
	
	# Espaço para colocar a função ou um jump para a função, whatever
	
	j fim_leitura					# Pula para função que quebra linha e pula para a main
	
# Função de remover morador	
cmd_rm_m:
	la $a0, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário
	addi $a0, $a0, 11				# Soma 11 ao endereço afim de ir para onde começa o numero do AP 
	addi $a1, $a0, 3				# Soma mais 3 aos 11 somados afim de ir para onde começa o nome do morador
	
	# Espaço para colocar a função ou um jump para a função, whatever
	
	j fim_leitura					# Pula para função que quebra linha e pula para a main
	
# Função de adicionar automóvel	
cmd_ad_a:
	la $a0, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário
	addi $a0, $a0, 8				# Soma 8 ao endereço afim de ir para onde começa o numero do AP 
	addi $a1, $a0, 3				# Somando 3 é onde começa o tipo do automóvel
	addi $a2, $a1, 2				# Somando mais 2 é onde começa o tipo do automóvel
	
	# Espaço para colocar a função ou um jump para a função, whatever. Lembrar que ainda é preciso chegar na cor do auto
	
	j fim_leitura					# Pula para função que quebra linha e pula para a main
	
# Função de remover automóvel	
cmd_rm_a:
	la $a0, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário
	addi $a0, $a0, 8				# Soma 8 ao endereço afim de ir para onde começa o numero do AP 
	addi $a1, $a0, 3				# Somando 3 é onde começa o modelo do automóvel
	addi $a2, $a1, 2				# Somando mais 2 é onde começa o tipo do automóvel
	
	# Espaço para colocar a função ou um jump para a função, whatever. Lembrar que ainda é preciso chegar na cor do auto
	
	j fim_leitura					# Pula para função que quebra linha e pula para a main
	
# Função de limpar AP
cmd_lp_ap:
	la $a0, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário
	addi $a0, $a0, 10				# Soma 10 ao endereço afim de ir para onde começa o numero do AP 
	
	# Espaço para colocar a função ou um jump para a função, whatever
	
	j fim_leitura					# Pula para função que quebra linha e pula para a main
	
# Função de informações de um AP especifico
cmd_if_ap:
	la $a0, terminal_cmd			# Lê o endereço do espaço que armazena o que foi digitado pelo usuário
	addi $a0, $a0, 8				# Soma 8 ao endereço afim de ir para onde começa o numero do AP 
	
	# Espaço para colocar a função ou um jump para a função, whatever
	
	j fim_leitura					# Pula para função que quebra linha e pula para a main
	
# Função de informações gerais dos APs	
cmd_if_g:
	
	# Espaço para colocar a função ou um jump para a função, whatever
	
	j fim_leitura					# Pula para função que quebra linha e pula para a main
	
# Função de salvar no arquivo
cmd_s:
	
	# Espaço para colocar a função ou um jump para a função, whatever
	
	j fim_leitura					# Pula para função que quebra linha e pula para a main
	
# Função de recarregar o arquivo	
cmd_r:
	
	# Espaço para colocar a função ou um jump para a função, whatever
	
	j fim_leitura					# Pula para função que quebra linha e pula para a main
	
# Função de formatar o arquivo	
cmd_f:
	
	# Espaço para colocar a função ou um jump para a função, whatever
	
	j fim_leitura					# Pula para função que quebra linha e pula para a main
	
# Função que escreve "Comando Inválido" no display MMIO
cmd_invalido:
	lw $t0, trsmttr_ctrl			# Lê o conteudo escrito no transmitter control no reg t0							
    andi $t1, $t0, 1        		# Faz a operação AND entre o valor contido no reg t0 e 1 a fim de isolar o último bit (bit "pronto")       		               		
    beq $t1, $zero, cmd_invalido	# Caso seja 0, o transmissor não está pronto para receber valores: continua o loop
	lb $t2, 0($s1)					# Carrega um byte da string "Comando Invalido" para ser impresso no MMIO					
	beq $t2, $zero, fim_leitura		# Caso o byte carregado seja 0, significa que a string terminou, daí vai para função que quebra linha e pula para a main
	sb $t2, trsmttr_data			# Escreve o caractere no display do MMIO	
	addi $s1, $s1, 1				# Soma 1 ao endereço da string "Comando Invalido" afim de ir para o proximo byte
	j cmd_invalido					# Jump para continuar o loop

# Função auxiliar ao fim de leitura de um comando
fim_leitura:
	jal quebra_linha				# Pula para função quebra_linha e volta
	j main							# Pula para main para continuar o loop geral do programa
					

