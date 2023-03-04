.eqv rcvr_ctrl 0xffff0000
.eqv rcvr_data 0xffff0004
.eqv trsmttr_ctrl 0xffff0008
.eqv trsmttr_data 0xffff000c

.data
	str_padrao: .asciiz "VIA-shell>> "	# String padr�o a ser exibida no MMIO
	barra_n: .byte 10					# Valor equivalente na tabela ASCII da quebra de linha (\n)
	terminal_cmd: .space 100			# Espa�o/Vari�vel para armazenar o que � digitado pelo usu�rio no MMIO
	
	str_cmd_ad_m: .asciiz "ad_morador-"		# String de comando para adicionar morador
	str_cmd_rm_m: .asciiz "rm_morador-"		# String de comando para remover morador
	str_cmd_ad_a: .asciiz "ad_auto-"		# String de comando para adicionar automovel
	str_cmd_rm_a: .asciiz "rm_auto-"		# String de comando para remover automovel
	str_cmd_lp_ap: .asciiz "limpar_ap-"		# String de comando para limpar apartamento
	str_cmd_if_ap: .asciiz "info_ap-"		# String de comando para informa��es de AP especifico
	str_cmd_if_g: .asciiz "info_geral"		# String de comando para informa��es dos APs em geral
	str_cmd_s: .asciiz "salvar"				# String de comando para salvar as infos num arquivo
	str_cmd_r: .asciiz "recarregar"			# String de comando para recarregar as infos do arquivo
	str_cmd_f: .asciiz "formatar"			# String de comando para formatar o arquivo
	msg_c_v: .asciiz "Comando Valido"		# String usada apenas para testes de comandos v�lidos digitados no MMIO
	msg_c_i: .asciiz "Comando Invalido"		# String usada apenas para testes de comandos inv�lidos digitados no MMIO
	
	apt_space: .space 7480  				#  espa�os dedicados para os apartamentos
 	localArquivo: .asciiz "C:/aps.txt"  			# local no computador onde o arquivo original se mantem

.text
main:

        jal leArquivo                              # pula ate a fun��o qeu ira ler o aquivo
        addi $s2, $a1, 0                        # salva o space em s2
        
	la $s0, msg_c_v					# L� o endere�o da string teste de comando v�lido
	la $s1, msg_c_i					# L� o endere�o da string teste de comando inv�lido
	la $a1, str_padrao				# L� o endere�o da string padr�o a ser exibida no MMIO
	jal shell_str_loop				# Pula para a fun��o que escreve a string padr�o no MMIO e volta
	la $a1, terminal_cmd			# L� o endere�o da vari�vel que armazena o que foi digitado no MMIO
	j rcvr_loop						# Pula para o loop que aguarda as inser��es no MMIO
	
# Fun��o que compara strings para ver se s�o iguais
compara_str:
	move $t2, $a2					# Movendo o valor do reg $a2 (range) para o reg $t2
	move $t3, $a3					# Movendo o valor do reg $a3 (contador) para o reg $t3
	beq $t2, $t3, str_igual			# Caso o contador chegue no range sem que algum caractere seja diferente, as strings s�o consideradas iguais
	lb $t0, 0($a0)					# L� o byte da string 1
	lb $t1, 0($a1)					# L� o byte da string 2
	bne $t0, $t1, str_diferente		# Caso sejam diferentes, pula pra fun��o que lida com isso
	addi $a0, $a0, 1				# Adiciona 1 ao endere�o da string 1 para ir para o pr�ximo caractere
	addi $a1, $a1, 1				# Adiciona 1 ao endere�o da string 2 para ir para o pr�ximo caractere
	addi $a3, $a3, 1				# Adiciona 1 ao contador
	j compara_str					# Jump para continuar o loop

# Fun��o que trata as strings caso sejam diferentes
str_diferente:
	addi $v0, $0, 1					# Retorna 1 em v0
	jr $ra							# Volta a execu��o do topo da pilha
	
# Fun��o que trata as strings caso sejam iguais
str_igual:
	move $v0, $0					# Retorna 0 em v0
	jr $ra							# Volta a execu��o do topo da pilha
	
# Fun��o que escreve a string padr�o do shell a ser exibinda no MMIO toda vez h� quebra de linha (e na primeira execu��o tamb�m)
shell_str_loop:
	lw $t0, trsmttr_ctrl		# L� o conteudo escrito no transmitter control no reg t0		
    andi $t1, $t0, 1        	# Faz a opera��o AND entre o valor contido no reg t0 e 1 a fim de isolar o �ltimo bit (bit "pronto")       		
    beq $t1, $zero, shell_str_loop		# Caso seja 0, o transmissor n�o est� pronto para receber valores: continua o loop
	lb $t2, 0($a1)						# Carrega um byte da string padr�o a ser impressa no MMIO
	beq $t2, $zero, go_back				# Caso seja 0: a string terminou, vai para fun��o que volta pra main
	sb $t2, trsmttr_data				# Caso n�o seja: escreve o byte no transmitter do MMIO
	addi $a1, $a1, 1					# Soma 1 ao endere�o da string padr�o para ir para o pr�ximo byte a ser escrito
	j shell_str_loop					# Jump para continuar o loop
	
# Fun��o auxiliar para voltar pra main (no momento s� serve pra isso)
go_back:
	jr $ra						# Pula para o topo da pilha de execu��o
	
# Fun��o que faz o loop do receiver (recebendo o que foi digitado pelo usu�rio no MMIO)
rcvr_loop:	
    lw $t0, rcvr_ctrl				# L� o conteudo escrito no receiver control no reg t0			          
    andi $t1, $t0, 1            	# Faz a opera��o AND entre o valor contido no reg t0 e 1 a fim de isolar o �ltimo bit (bit "pronto")	
    beq $t1, $zero, rcvr_loop		# Caso seja 0, n�o est� pronto: o caractere ainda n�o foi completamente lido no Receiver Data
    lb $a0, rcvr_data				# Caso seja 1, est� pronto: aqui o caractere escrito no terminal � lido no Receiver Data
    sb $a0, 0($a1)					# Guarda o caractere lido no espa�o de mem�ria "terminal_cmd" que ser� usado para verificar se o comando escrito � aceito
    lb $t0, barra_n					# L� o valor do "\n" (10 na tabela ASCII) para saber se o usu�rio deu um "enter"
    beq $a0, $t0, verifica_cmds		# Caso o usu�rio d� "enter" vai para fun��o que verifica se o comando � v�lido
    j trsmttr_loop					# Pula para fun��o que faz o loop do transmitter (para escrever no MMIO o que foi digitado)

# Fun��o que quebra a linha no display do MMIO
quebra_linha:
	lw $t0, trsmttr_ctrl			# L� o conteudo escrito no transmitter control no reg t0		
    andi $t1, $t0, 1               	# Faz a opera��o AND entre o valor contido no reg t0 e 1 a fim de isolar o �ltimo bit (bit "pronto") 
    beq $t1, $zero, quebra_linha    # Caso seja 0, o transmissor n�o est� pronto para receber valores: continua o loop
	lb $t0, barra_n					# L� o valor do "\n" (10 na tabela ASCII) para inserir no display do MMIO
	sb $t0, trsmttr_data			# Escreve o "\n" ("enter") no display do MMIO
	jr $ra							# Pula para o topo da pilha de execu��o

# Fun��o que faz o loop do transmitter (para escrever no MMIO o que foi digitado)
trsmttr_loop:
    lw $t0, trsmttr_ctrl			# L� o conteudo escrito no transmitter control no reg t0		
    andi $t1, $t0, 1               	# Faz a opera��o AND entre o valor contido no reg t0 e 1 a fim de isolar o �ltimo bit (bit "pronto")	
    beq $t1, $zero, trsmttr_loop	# Caso seja 0, o transmissor n�o est� pronto para receber valores: continua o loop
    sb $a0, trsmttr_data			# Escreve o caractere no display do MMIO
    addi $a1, $a1, 1				# Soma 1 ao endere�o do espa�o de mem�ria "terminal_cmd" (usado para guardar o que usu�rio digitou)
    j rcvr_loop						# Pula para fun��o que faz o loop do receiver (para ler o pr�ximo caractere que foi digitado)
    
# Fun��o que verifica se o comando digitado � v�lido    
verifica_cmds:
	jal quebra_linha				# Jump  para fun��o que quebra linha no display do MMIO
	
	sb $0, 0($a1)					# Subistitui o ultimo caractere digitado no MMIO ("\n") por 0, afim de determinar o fim do comando
	
	la $a0, str_cmd_ad_m			# L� o endere�o da string de comando para adicionar morador
	la $a1, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio
	addi $a2, $0, 11				# Adiciona a quantidade de caracteres necess�rias para a compara��o
	move $a3, $0					# Instanciona um contador para compara_str
	jal compara_str					# Pula para fun��o que compara strings e volta
	beq $v0, $0, cmd_ad_m			# Caso $v0 volte da compara��o com valor 0 significa que o comando digitado � o de adicionar morador, dai pula para fun��o respons�vel
	
	la $a0, str_cmd_rm_m			# L� o endere�o da string de comando para remover morador
	la $a1, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio
	addi $a2, $0, 11				# Adiciona a quantidade de caracteres necess�rias para a compara��o
	move $a3, $0					# Instanciona um contador para compara_str
	jal compara_str					# Pula para fun��o que compara strings e volta
	beq $v0, $0, cmd_rm_m			# Caso $v0 volte da compara��o com valor 0 significa que o comando digitado � o de remover morador, dai pula para fun��o respons�vel
	
	la $a0, str_cmd_ad_a			# L� o endere�o da string de comando para adicionar automovel
	la $a1, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio
	addi $a2, $0, 8					# Adiciona a quantidade de caracteres necess�rias para a compara��o
	move $a3, $0					# Instanciona um contador para compara_str			
	jal compara_str					# Pula para fun��o que compara strings e volta
	beq $v0, $0, cmd_ad_a			# Caso $v0 volte da compara��o com valor 0 significa que o comando digitado � o de adicionar automovel, dai pula para fun��o respons�vel
	
	la $a0, str_cmd_rm_a			# L� o endere�o da string de comando para remover automovel
	la $a1, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio	
	addi $a2, $0, 8					# Adiciona a quantidade de caracteres necess�rias para a compara��o
	move $a3, $0					# Instanciona um contador para compara_str		
	jal compara_str					# Pula para fun��o que compara strings e volta
	beq $v0, $0, cmd_rm_a			# Caso $v0 volte da compara��o com valor 0 significa que o comando digitado � o de remover automovel, dai pula para fun��o respons�vel
	
	la $a0, str_cmd_lp_ap			# L� o endere�o da string de comando para limpar apartamento
	la $a1, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio
	addi $a2, $0, 10				# Adiciona a quantidade de caracteres necess�rias para a compara��o
	move $a3, $0					# Instanciona um contador para compara_str			
	jal compara_str					# Pula para fun��o que compara strings e volta
	beq $v0, $0, cmd_lp_ap			# Caso $v0 volte da compara��o com valor 0 significa que o comando digitado � o de limpar apartamento, dai pula para fun��o respons�vel
	
	la $a0, str_cmd_if_ap			# L� o endere�o da string de comando para informa��es de AP especifico
	la $a1, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio
	addi $a2, $0, 8					# Adiciona a quantidade de caracteres necess�rias para a compara��o
	move $a3, $0					# Instanciona um contador para compara_str			
	jal compara_str					# Pula para fun��o que compara strings e volta
	beq $v0, $0, cmd_if_ap			# Caso $v0 volte da compara��o com valor 0 significa que o comando digitado � o de informa��es de AP especifico, dai pula para fun��o respons�vel
	
	la $a0, str_cmd_if_g			# L� o endere�o da string de comando para informa��es dos APs em geral
	la $a1, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio
	addi $a2, $0, 10				# Adiciona a quantidade de caracteres necess�rias para a compara��o
	move $a3, $0					# Instanciona um contador para compara_str			
	jal compara_str					# Pula para fun��o que compara strings e volta
	beq $v0, $0, cmd_if_g			# Caso $v0 volte da compara��o com valor 0 significa que o comando digitado � o de informa��es dos APs em geral, dai pula para fun��o respons�vel
	
	la $a0, str_cmd_s				# L� o endere�o da string de comando para salvar as infos num arquivo
	la $a1, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio
	addi $a2, $0, 6				# Adiciona a quantidade de caracteres necess�rias para a compara��o
	move $a3, $0					# Instanciona um contador para compara_str			
	jal compara_str					# Pula para fun��o que compara strings e volta
	beq $v0, $0, cmd_s				# Caso $v0 volte da compara��o com valor 0 significa que o comando digitado � o de salvar as infos num arquivo, dai pula para fun��o respons�vel
	
	la $a0, str_cmd_r				# L� o endere�o da string de comando para recarregar as infos do arquivo
	la $a1, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio
	addi $a2, $0, 10				# Adiciona a quantidade de caracteres necess�rias para a compara��o
	move $a3, $0					# Instanciona um contador para compara_str			
	jal compara_str					# Pula para fun��o que compara strings e volta
	beq $v0, $0, cmd_r				# Caso $v0 volte da compara��o com valor 0 significa que o comando digitado � o de recarregar as infos do arquivo, dai pula para fun��o respons�vel
	
	la $a0, str_cmd_f				# L� o endere�o da string de comando para formatar o arquivo
	la $a1, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio
	addi $a2, $0, 8				# Adiciona a quantidade de caracteres necess�rias para a compara��o
	move $a3, $0					# Instanciona um contador para compara_str			
	jal compara_str					# Pula para fun��o que compara strings e volta
	beq $v0, $0, cmd_f				# Caso $v0 volte da compara��o com valor 0 significa que o comando digitado � o de formatar o arquivo, dai pula para fun��o respons�vel
	
	j cmd_invalido					# Caso n�o entre em nenhum dos branchs significa que o comando digitado � inv�lido, da� pula para fun��o que escreve "Comando Inv�lido" no display MMIO
	
# Fun��o de adicionar morador	
cmd_ad_m:
	j cmd_valido
	la $a0, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio
	addi $a0, $a0, 11				# Soma 11 ao endere�o afim de ir para onde come�a o numero do AP 
	move $t1, $a0
	addi $t1, $t1, 2
	move $t2, $0
	sb $t2, 0($t1)
	addi $a1, $a0, 3				# Soma mais 2 aos 11 somados afim de ir para onde come�a o nome do morador
	
	incerirPessoa:  # vou considerar que o valor de $a0 apartamento e $a1 esta com o nome a ser incerrido: em $s2 esta a lista de itens em $s2 estara a posi��o inicial dos APs
# os possiveis erros est�o em $v0 sendo eles 1 ou 2, 1w = apartamento n�o encontrado
  
  addi $t7 , $s2, 0  # carrega a primeira posi��o do espa�o disponivel para o sistema de apartamneto
  addi $t2, $t7, 7480 # maior valor possivel  a ser escrito no sistema
  addi $t4, $a1, 0  #  salva o que esta em a1, para utilizar em algumas outras fun�oes
  
  verificador_andar: 
    addi $a1, $t7, 0  # carrega a  posi��o do espa�o disponivel em vigor para ser comparada
    addi $t9, $ra, 0  # salva onde estava no codigo
    addi $t8, $a0, 0  # salva a posi��o inicial do meu ap a ser comparado
    jal strcmp  # verifica se as strings s�o iguais (caso sejam: o apartamento foi achado)
    addi $ra, $t9, 0 # recupera onde estava no codigo 
    addi $a0, $t8, 0 # recupera a posi��o inicial do meu ap a ser comparado
    beq $v0, 0, ap_insere  # confere se as strings s�o iguais  se sim envia para a inser��o

    addi $t7, $t7, 187 # pula para o numero do proximo apartamento
    beq $t2, $t7, ap_n_encontrado  # verifica se a contagem ja cobriu todos os apartamentos
    j verificador_andar  # retorna ao inicio do loop
    
  ap_insere:  # se chegarmos aqui � porque o apartamento foi encontrado, agora vamos verificar se o ap pode receber mais uma pessoa
    
    addi $t7, $t7, 3 # tendo recebi o apartamento vamos vasculhar jogando para a 1 posi��o das pessoas
    addi $t5, $0, 0 # inicia meu contador de pessoas caso seja 5 o a paratamento est� cheio
    
    vaga:  # inicia um loop que verifica vaga por vaga
      
      lb $t3, 0($t7)  # carrega 1  ��o de de cada nome para saber se aquele ap esta disponivel
      beq $t3, 0, vaga_disponivel  # pula para a area de escriata ja que a vaga esta disponivel
      addi $t7, $t7, 20  # pula para o proximo nome a verificar
      addi $t5, $t5, 1  # verifica se o total de pessoas daquele ap ja foi verificado
      beq $t5, 5, apt_cheio  # caso todos os possiveis locais para incerir pessoas foram preenchidos
      j vaga  # retorna ao loop

  vaga_disponivel:  # se chegarmos aqui � por que o nome pode ser incerido
    
    addi $a0, $t7, 0 # carrega em a0 o que devemos incerir no local do nome
    addi $a1, $t4, 0 # carrega o espa�o a ser incerido
    addi $t9, $ra, 0 # salva a posi��o original do arquivo
    jal strcpy  # copia a string no novo local controlando o numero de caracteres par aque o mesmo n�o utrapasse 19
    addi $ra, $t9, 0 # recupera a posi��o original do arquivo

    jr $ra # ja que a fun��o foi bem sucedida retorna ao inicio
    
    apt_cheio: # caso o apartamento esteja cheio retor na o erro 2
      addi $v0, $0, 2 # carrega 2 no retorno 
      jr $ra # acaba a fun��o
	
	j fim_leitura					# Pula para fun��o que quebra linha e pula para a main
	
# Fun��o de remover morador	
cmd_rm_m:
	la $a0, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio
	addi $a0, $a0, 11				# Soma 11 ao endere�o afim de ir para onde come�a o numero do AP 
	addi $a1, $a0, 3				# Soma mais 3 aos 11 somados afim de ir para onde come�a o nome do morador
	
	remover_pessoa:  # deve receber em a0 o apartamento e em a1 o nome
  
  move $t1, $a1 # salva o nome da pessoa para utiliza��o futura
  move $a1, $s2 # recebe a posi��o inicial do meu space
  move $t9, $a0  # salva o apartamento para utiliza��o posterior
  
  # salva as variaveis utilizadas para evitar problemas 
  addi $sp, $sp, -12  # salva o espa�o em memoria par asalvar os registradores
  sw $t9, 8($sp) # salvando o apartamento na memoria
  sw $t1, 4($sp)  # salvando o nome da pessoa
  sw $ra, 0($sp)  # salvando o registrador de onde estavamos no codigo
    
  jal verifica_andar
  
  
  # carregha todas os registradores usadas
  lw $ra, 0($sp)  # resgatando o registrador de onde estavamos no codigo
  lw $t1, 4($sp)  # resgatando o nome da pessoa
  lw $t9, 8($sp)  # resgatando o apartamento na memoria
  addi $sp, $sp, 12  # resgatando o espa�o em memoria par asalvar os registradores
  
  beq $v0, -1, ap_n_encontrado  # verifica se o aptamento foi encontrado 
  addi $t2, $v0, 3  # adicionando 3 no ponteiro ele ira ate a posi��o do primeiro nome dos moradores
  addi $t3, $0, 1 # inicia um contador par asaber quantas pessoas foramverificadas
  j  remover_pessoa_ac  # se chegar aqui o anadar foi encontrado
  
  remover_pessoa_ac: #  inicializa a possivel remo��o do morador
    move $a0, $t2  # adiciona ao argumento a0 a posi��o que ele deve utilizar na busca peno nome usado no comando
    move $a1,  $t1  # adiciona ao argumento a1 a posi��o que ele deve utilizar na busca
    
    # salva as variaveis utilizadas para evitar problemas 
    addi $sp, $sp, -20  # libera espa�o na memoria para salvar os registradores antes da fun��o
    sw $t9, 16($sp)  # armazena o apartamento para verifica��o futura
    sw $t1, 12($sp)  # armazena o registrador com a posi��o do nome na fun��o ne memoria
    sw $t2, 8($sp)  # armazena o registrador com a posi��o do nome nos apartamentos
    sw $t3, 4($sp)  # armazena o registrador com a contagem de pessoas
    sw $ra, 0($sp)  # salvando o registrador de onde estavamos no codigo
    
    jal strcmp  # carregar a string a ser removida em a0 e em a1 o ponteiro no momento 
    
    #  recarrega as variaveis pos fun��o
    lw $ra, 0($sp) # recebendo o registrador de onde estavamos no codigo
    lw $t3, 4($sp)  # recebendo o registrador com a contagem de pessoas
    lw $t2, 8($sp)  # recebendo o registrador com a posi��o do nome nos apartamentos
    lw $t1, 12($sp)  # recebendo o registrador com a posi��o do nome na fun��o ne memoria
    lw $t9, 16($sp)  # resgatando o espa�o em memoria par asalvar os registradores
    addi $sp, $sp, 20  # recebendo o espa�o na memoria para salvar os registradores antes da fun��o
    
    addi $t3, $t3, 1  # adiciona um ao contador de pessoas verificadas
    beq $v0, 0, pessoa_encontrada  # verifica se o nome a ser removido � esse
    addi $t2, $t2, 20 # pula para o proximo nome
    beq $t3, 5, pessoa_n_enc  #  caso a pessoa n�o seja encontrada
    j remover_pessoa_ac  # retorna ao loop

  pessoa_n_enc:
    addi $v0, $0, 1 # carrega 1 em v0
    jr $ra # encerra a fun��o

  pessoa_encontrada:  # fun��o que vai remover a pessoa em si
    addi $t1,$0, 0  #  adiciona 0 a t1 para que o mesmo substitua o nome da pessoa
    lb $t3, 0($t2)  # carrega o qeu esta na memoria para verifica rse o mesmo ja foi removido
    beq $t3, 0, apagado  # verifica se ele foi removido | caso seja va para apagado
    sb $t1, 0($t2)  #  remove o caracter em quest�o
    addi $t2, $t2, 1  # adiciona 1 para buscar o proximo caracter
    j pessoa_encontrada  # retorna ao loop
  
  apagado:  # apagado:  deve verificar a limpesa do AP
  
    addi $sp, $sp, -8
    sw $t9, 0($sp)
    sw $ra, 4($sp)
    move $a0, $t9
    
    jal verifica_ap  # verifica se o apartamneto esta vasio
    
    lw $ra, 4($sp)
    lw $t9, 0($sp)
    addi $sp, $sp, 8
    
    beq $v0, 2, esvasia_apt  # caso o ap esteja vasio, limpar ele inteiro
    jr $ra # encerra a fun��o
	
	j fim_leitura					# Pula para fun��o que quebra linha e pula para a main
	
# Fun��o de adicionar autom�vel	
cmd_ad_a:
	la $a0, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio
	addi $a0, $a0, 8				# Soma 8 ao endere�o afim de ir para onde come�a o numero do AP 
	addi $a1, $a0, 3				# Somando 3 � onde come�a o tipo do autom�vel
	addi $a2, $a1, 2				# Somando mais 2 � onde come�a o tipo do autom�vel
	
	# Espa�o para colocar a fun��o ou um jump para a fun��o, whatever. Lembrar que ainda � preciso chegar na cor do auto
	
	j fim_leitura					# Pula para fun��o que quebra linha e pula para a main
	
# Fun��o de remover autom�vel (falta confirmar com o professor se vai funcionar assim mesmo)	
cmd_rm_a:
	la $a0, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio
	addi $a0, $a0, 8				# Soma 8 ao endere�o afim de ir para onde come�a o numero do AP 
	addi $a1, $a0, 3				# Somando 3 � onde come�a o modelo do autom�vel
	
	# Espa�o para colocar a fun��o ou um jump para a fun��o, whatever
	
	j fim_leitura					# Pula para fun��o que quebra linha e pula para a main
	
# Fun��o de limpar AP
cmd_lp_ap:
	la $a0, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio
	addi $a0, $a0, 10				# Soma 10 ao endere�o afim de ir para onde come�a o numero do AP 
	
	esvasia_apt:  # recebe em a0 o endere�o do apt e em a1 a horigem dos apartamentos
  addi $sp, $sp, -4  # armazena o ra para utiliza��o futura
  sw $ra, 0($sp)  # armazena o ra para utiliza��o futura
  
  jal verifica_andar
  
  lw $ra, 0($sp)  # recupera o ra para utiliza��o futura
  addi $sp, $sp, 4 # recupera o ra para utiliza��o futura
  
  beq $v0, -1, ap_n_encontrado  # verifica se o apartamento n�o foi encontrado
  addi $t3, $v0, 187  #  gera o fim da lisat do aparatamento
  addi $t1, $v0, 3  # vai ate o inicio do arrey a ser testado
  addi $t2, $0, 0  # inicia o contrador de caracteres
  
  removedor: # remove todo o apartamento em si
    sb $t2, 0($t1)  # salva /0 na memoria
    addi $t1, $t1, 1 # adiciona 1 ao contador
    bne $t1, $t3, removedor  # verifica o fim da remo��o
    jr $ra  #  velta para o fim da dun��o
	
	j fim_leitura					# Pula para fun��o que quebra linha e pula para a main
	
# Fun��o de informa��es de um AP especifico
cmd_if_ap:
	la $a0, terminal_cmd			# L� o endere�o do espa�o que armazena o que foi digitado pelo usu�rio
	addi $a0, $a0, 8				# Soma 8 ao endere�o afim de ir para onde come�a o numero do AP 
	
	# Espa�o para colocar a fun��o ou um jump para a fun��o, whatever
	
	j fim_leitura					# Pula para fun��o que quebra linha e pula para a main
	
# Fun��o de informa��es gerais dos APs	
cmd_if_g:
	
	# Espa�o para colocar a fun��o ou um jump para a fun��o, whatever
	
	j fim_leitura					# Pula para fun��o que quebra linha e pula para a main
	
# Fun��o de salvar no arquivo
cmd_s:
	
	# Espa�o para colocar a fun��o ou um jump para a fun��o, whatever
	
	j fim_leitura					# Pula para fun��o que quebra linha e pula para a main
	
# Fun��o de recarregar o arquivo	
cmd_r:
	
	# Espa�o para colocar a fun��o ou um jump para a fun��o, whatever
	
	j fim_leitura					# Pula para fun��o que quebra linha e pula para a main
	
# Fun��o de formatar o arquivo	
cmd_f:
	
	# Espa�o para colocar a fun��o ou um jump para a fun��o, whatever
	
	j fim_leitura					# Pula para fun��o que quebra linha e pula para a main
	
# Fun��o que escreve "Comando Inv�lido" no display MMIO
cmd_invalido:
	lw $t0, trsmttr_ctrl			# L� o conteudo escrito no transmitter control no reg t0							
    andi $t1, $t0, 1        		# Faz a opera��o AND entre o valor contido no reg t0 e 1 a fim de isolar o �ltimo bit (bit "pronto")       		               		
    beq $t1, $zero, cmd_invalido	# Caso seja 0, o transmissor n�o est� pronto para receber valores: continua o loop
	lb $t2, 0($s1)					# Carrega um byte da string "Comando Invalido" para ser impresso no MMIO					
	beq $t2, $zero, fim_leitura		# Caso o byte carregado seja 0, significa que a string terminou, da� vai para fun��o que quebra linha e pula para a main
	sb $t2, trsmttr_data			# Escreve o caractere no display do MMIO	
	addi $s1, $s1, 1				# Soma 1 ao endere�o da string "Comando Invalido" afim de ir para o proximo byte
	j cmd_invalido					# Jump para continuar o loop
	
cmd_valido:
	lw $t0, trsmttr_ctrl			# L� o conteudo escrito no transmitter control no reg t0							
    andi $t1, $t0, 1        		# Faz a opera��o AND entre o valor contido no reg t0 e 1 a fim de isolar o �ltimo bit (bit "pronto")       		               		
    beq $t1, $zero, cmd_valido	# Caso seja 0, o transmissor n�o est� pronto para receber valores: continua o loop
	lb $t2, 0($s0)					# Carrega um byte da string "Comando Invalido" para ser impresso no MMIO					
	beq $t2, $zero, fim_leitura		# Caso o byte carregado seja 0, significa que a string terminou, da� vai para fun��o que quebra linha e pula para a main
	sb $t2, trsmttr_data			# Escreve o caractere no display do MMIO	
	addi $s0, $s0, 1				# Soma 1 ao endere�o da string "Comando Invalido" afim de ir para o proximo byte
	j cmd_valido					# Jump para continuar o loop

# Fun��o auxiliar ao fim de leitura de um comando
fim_leitura:
	jal quebra_linha				# Pula para fun��o quebra_linha e volta
	j main							# Pula para main para continuar o loop geral do programa
	
#  espa�o para fun�oes auxiliares
					
strcmp:  # inicia a fun��o comparador
    
    loop_principal: # inicia o loop principal da fun��o
      
      lb $t0, 0($a0)  # carrega o valor a partir de a0 a ser avaliado 
      addi $a0, $a0, 1  # incrementa para que a proxima letra seja pega.
      
      lb $t1, 0($a1)  # carrega o valor a partir de a1 a ser avaliado 
      addi $a1, $a1, 1  # incrementa para que a proxima letra seja pega.
      
      bne $t0, $t1, final_diferente  #  verifica se os valores analizados s�o diferentes
      
      beq $t0, $0, filtro_1  #  verifica se os dois valores s�o iguais
      beq $t1, $0, final_diferente  #  chegando aqui verifica-se se a outra string tenha acabado ja que se a mesma acabou ambas s�o diferentes
      
      j loop_principal  #  rotorna ao loop principal caso nenhum criterio de parada seja atendido
      
      filtro_1:  #  verifica se os resultados anlizados s�o iguais a 0, ja que se � 0 significa que ambas as strings s�o iguais
        beq $t1, $0, final_igual  # caso sej�o iguais va poara final_igual
        j final_diferente  # sendo diferente, va para final_diferente
      
      final_diferente:  # para os casos de 1 - uma string encerrar antes da outra, 2 - o primeiro valor diferente entre um e outro
      
        sub $v0, $t0, $t1 # Realiza uma subtra��o entre o ultimo valor de a0 e o ultimo valor de a1, para atender as diretrizes da fun��o, alem de devolver o resultado em v0.
        jr $ra #  retorna a execu��o normal do programa 
        
      final_igual:  # para o caso de as 2 strings serem iguais 
         
         addi $v0, $0, 0  # o retorno em v0 deve ser 0
         jr $ra  #  retorna a execu��o normal do programa 

strcpy: #espa�o na memoria em a0, a1 a mensagema ser copiada

  addi $t2, $a0, 0  # adiciona os endere�os a t2
  addi $t3, $a1, 0  # adiciona os endere�os as t3
  addi $t4, $0, 0  # inicia um contador de caracteraes (19)
  
  loop:
  
    lb $t1, 0($t3) # carrega em t1 o conteudo de a0 no momento
    addi $t3, $t3, 1  # pula para a proxima casa de a0
    
    sb $t1, 0($t2) # carrega em t2 o conteudo de a1 no momento
    addi $t2, $t2, 1  # pula para a proxima casa de a0
    addi $t4, $t4, 1
    beq $t4, 19, fim_str
    bne $t0, $t1, loop # cetificace de que a string ainda n�o acabou
  
  addi $t1, $0, 0 #carrega o valor a ser incerido na copia "/0"
  sb $t1, 0($t2) # valor a ser incerido na copia "/0"
  addi $v0, $a0, 0  # retorna a fun��o em v0
  jr $ra  # rotorna ao fluxo normal
  
  fim_str:
  addi $t1, $0, 0 #carrega o valor a ser incerido na copia "/0"
  sb $t1, 0($t2) # valor a ser incerido na copia "/0"
  addi $v0, $a0, 0  # retorna a fun��o em v0
  jr $ra  # rotorna ao fluxo normal
         
verifica_ap: # Percorre um apartamento verificando se est� vazio - O n�mero do ap deve ser informado em a0
  addi $sp, $sp, -4  # libera espa�o na memoria para salvar os registradores antes da fun��o
  sw $ra, 0($sp)  # salvando o registrador de onde estavamos no codigo
  
  jal verifica_andar
  
  lw $ra, 0($sp) # recebendo o registrador de onde estavamos no codigo
  addi $sp, $sp, 4  # recebendo o espa�o na memoria para salvar os registradores antes da fun��o
  
  addi $t2, $v0, 3 # Carrega a posi��o da primeira pessoa do AP
  addi $t4, $0, 0 # inicia meu contador de pessoas caso seja 5 o a paratamento est� cheio
  
  
  vaga_ap:
    lb $t3, 0($t2)  # carrega 1 posi��o de cada nome para saber se aquele ap esta disponivel
    bne $t3, 0, apt_ocupado  # pula para a area de escriata ja que a vaga esta disponivel
    addi $t2, $t2, 20  # pula para o proximo nome a verificar
    addi $t4, $t4, 1  # Incrementa o contador de pessoas verificadas
    beq $t4, 5, apt_vazio  # caso todos os possiveis locais para incerir pessoas foram preenchidos
    j vaga_ap # Reinicia o loop
      
      
  apt_ocupado: # Caso exista uma pessoa no AP, retorna a fun��o.
    addi $v0, $0, 1 # Carrega 1 em v0 
    jr $ra # Retorna a fun��o
    
  apt_vazio: # Caso o apartamento esteja vazio, retorna a fun��o.
    addi $v0, $0, 2 # Carrega 2 em v0 
    jr $ra # Retorna a fun��o

verifica_andar: # Em a0 deve ser disposto o andara ser verificado e em a1 o ponteiro para o inicio do space de andares
  
  move $a1, $s2
  move $t6, $a1  # salva a posi��o inicial de a1
  addi $t7, $0, 0  # salva em t1 0
  addi $t7, $a1, 7480  # t7 marca o fim doa aps
  move $t5, $a0  # armazena o ponteiro do apartamento incerido 
  
  verificador_andara: 
    move $a0, $t5 # passa o ponteiro do apartamento incerido 
    addi $a1, $t6, 0  # carrega a  posi�aoo do espa�o disponivel em vigor para ser comparada
    addi $t8, $ra, 0  # salva onde estava no codigo
    jal strcmp  # verifica se as strings s�o iguais (caso sejam: o apartamento foi achado)
    addi $ra, $t8, 0 # recupera onde estava no codigo
    beq $v0, 0, ap_enc  # confere se as strings s�o iguais  se sim envia para a inser��o

    addi $t6, $t6, 187 # pula para o numero do proximo apartamento
    beq $t6, $t7, apt_n_achado  # verifica se a contagem ja cobriu todos os apartamentos
    j verificador_andara  # retorna ao inicio do loop
    
  ap_enc:  # retorna a posi��o que dio andar
    move $v0, $t6  #  move para v0 o retorno
    jr $ra  # retorna para a execu��o do arquivo
    
  apt_n_achado: # caso o ap n seja achado retorna -1
    addi $v0, $0, -1   # move para v0 o retorno
    jr $ra # retorna para a execu��o do arquivo
    
ap_n_encontrado:  # devolve 1 em v0 pq o ap n�o foi encontrado
    addi $v0, $0, 1 # carrega 1 em v0
    jr $ra # encerra a fun��o
    
leArquivo:

  #Abre arquivo para ler

	li $v0, 13			#abrir arquivo
	la $a0, localArquivo 		#informa endereço
	li $a1, 0 			#informa parametro leitura
	syscall 			#descritor pra $v0

        move $s1, $v0 			#copia o descritor de $v0 para $s0
	move $a0, $s1 			#copia o descritor de $s0 para $a0

  #De fato lê
	
	li $v0, 14 			#ler conteudo do arquivo referenciado por $a0
	la $a1, apt_space 	#armazenamento
	li $a2, 7480 			#tamanho do armazenamento
	syscall 			#leitura realizada do conteudo guardado em $a1

  #Fecha o arquivo

        li $v0, 16 			#fecha arquivo
	move $a0, $s1 			#copia para o parametro $a0 o descritor guarado em $s0
	syscall 			#executa fun��o

	jr $ra	
