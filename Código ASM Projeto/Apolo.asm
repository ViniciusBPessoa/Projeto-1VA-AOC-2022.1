.eqv rcvr_ctrl 0xffff0000
.eqv rcvr_data 0xffff0004
.eqv trsmttr_ctrl 0xffff0008
.eqv trsmttr_data 0xffff000c

.data
	str_padrao: .asciiz "VIA-shell>> "	# String padrão a ser exibida no MMIO
	barra_n: .byte 10					# Valor equivalente na tabela ASCII da quebra de linha (\n)
	terminal_cmd: .space 100			# Espaço/Variável para armazenar o que é digitado pelo usuário no MMIO
	
	cmd_ad_m: .asciiz "ad_morador-"		# String de comando para adicionar morador
	cmd_rm_m: .asciiz "rm_morador-"		# String de comando para remover morador
	cmd_ad_a: .asciiz "ad_auto-"		# String de comando para adicionar automovel
	cmd_rm_a: .asciiz "rm_auto-"		# String de comando para remover automovel
	cmd_lp_ap: .asciiz "limpar_ap-"		# String de comando para limpar apartamento
	cmd_if_ap: .asciiz "info_ap-"		# String de comando para informações de AP especifico
	cmd_if_g: .asciiz "info_geral"		# String de comando para informações dos APs em geral
	cmd_s: .asciiz "salvar"				# String de comando para salvar as infos num arquivo
	cmd_r: .asciiz "recarregar"			# String de comando para recarregar as infos do arquivo
	cmd_f: .asciiz "formatar"			# String de comando para formatar o arquivo
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
	lw $t0, trsmttr_ctrl					
    andi $t1, $t0, 1               		
    beq $t1, $zero, shell_str_loop
	lb $t2, 0($a1)
	beq $t2, $zero, go_back
	sb $t2, trsmttr_data
	addi $a1, $a1, 1
	j shell_str_loop
	
go_back:
	jr $ra
	
rcvr_loop:	
    lw $t0, rcvr_ctrl					          
    andi $t1, $t0, 1            		
    beq $t1, $zero, rcvr_loop
    lb $a0, rcvr_data
    sb $a0, 0($a1)					
    lb $t0, barra_n
    beq $a0, $t0, verifica_cmds
    j trsmttr_loop	

quebra_linha:
	lw $t0, trsmttr_ctrl					
    andi $t1, $t0, 1               		
    beq $t1, $zero, quebra_linha
	lb $t0, barra_n
	sb $t0, trsmttr_data
	jr $ra				

trsmttr_loop:
    lw $t0, trsmttr_ctrl					
    andi $t1, $t0, 1               		
    beq $t1, $zero, trsmttr_loop	
    sb $a0, trsmttr_data
    addi $a1, $a1, 1
    j rcvr_loop	
    
verifica_cmds:
	jal quebra_linha
	
	sb $0, 0($a1)
	
	la $a0, cmd_ad_m
	la $a1, terminal_cmd
	jal compara_str
	beq $v0, $0, cmd_valido
	
	la $a0, cmd_rm_m
	la $a1, terminal_cmd
	jal compara_str
	beq $v0, $0, cmd_valido
	
	la $a0, cmd_ad_a
	la $a1, terminal_cmd
	jal compara_str
	beq $v0, $0, cmd_valido
	
	la $a0, cmd_rm_a
	la $a1, terminal_cmd
	jal compara_str
	beq $v0, $0, cmd_valido
	
	la $a0, cmd_lp_ap
	la $a1, terminal_cmd
	jal compara_str
	beq $v0, $0, cmd_valido
	
	la $a0, cmd_if_ap
	la $a1, terminal_cmd
	jal compara_str
	beq $v0, $0, cmd_valido
	
	la $a0, cmd_if_g
	la $a1, terminal_cmd
	jal compara_str
	beq $v0, $0, cmd_valido
	
	la $a0, cmd_s
	la $a1, terminal_cmd
	jal compara_str
	beq $v0, $0, cmd_valido
	
	la $a0, cmd_r
	la $a1, terminal_cmd
	jal compara_str
	beq $v0, $0, cmd_valido
	
	la $a0, cmd_f
	la $a1, terminal_cmd
	jal compara_str
	beq $v0, $0, cmd_valido
	
	j cmd_invalido
	
cmd_valido:
	lw $t0, trsmttr_ctrl					
    andi $t1, $t0, 1               		
    beq $t1, $zero, cmd_valido
	lb $t2, 0($s0)
	beq $t2, $zero, fim_leitura
	sb $t2, trsmttr_data
	addi $s0, $s0, 1
	j cmd_valido

cmd_invalido:
	lw $t0, trsmttr_ctrl					
    andi $t1, $t0, 1               		
    beq $t1, $zero, cmd_invalido
	lb $t2, 0($s1)
	beq $t2, $zero, fim_leitura
	sb $t2, trsmttr_data
	addi $s1, $s1, 1
	j cmd_invalido

fim_leitura:
	jal quebra_linha
	j main
					

