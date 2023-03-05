.data
  
  
  func: .asciiz "ad_morador-02-vinicius"
  func2: .asciiz "rm_morador-02-vinicius"

  apt_space: .space 7480  #  declaração de todo o espaço para todos os apartamentos para verificaïção
  localArquivo: .asciiz "C:/aps.txt"

.text

main:
   
  jal leArquivo
  addi $s2, $a1, 0
   
  la $a0, func
  addi $a0, $a0, 11				# Soma 11 ao endereço afim de ir para onde começa o numero do AP 
  move $t1, $a0					#  ad_morador-02/0vini
  addi $t1, $t1, 2
  move $t2, $0
  sb $t2, 0($t1)
  addi $a1, $a0, 3				# Soma mais 2 aos 11 somados afim de ir para onde começa o nome do morador

  jal inserirPessoa
  
  la $a0, func2
  addi $a0, $a0, 11				# Soma 11 ao endereço afim de ir para onde começa o numero do AP 
  move $t1, $a0					#  ad_morador-02/0vini
  addi $t1, $t1, 2
  move $t2, $0
  sb $t2, 0($t1)
  addi $a1, $a0, 3				# Soma mais 2 aos 11 somados afim de ir para onde começa o nome do morador

  jal remover_pessoa
  

  
  j fim

#########################################################################################################################

inserirPessoa:  # vou considerar que o valor de $a0 apartamento e $a1 esta com o nome a ser incerrido: em $s2 esta a lista de itens em $s2 estara a posição inicial dos APs
# os possiveis erros estão em $v0 sendo eles 1 ou 2, 1w = apartamento não encontrado
  
  addi $t7 , $s2, 0  # carrega a primeira posição do espaço disponivel para o sistema de apartamneto
  addi $t2, $t7, 7480 # maior valor possivel  a ser escrito no sistema
  addi $t4, $a1, 0  #  salva o que esta em a1, para utilizar em algumas outras funçoes
  
  addi $sp, $sp, -16
  sw $t7, 0($sp)
  sw $s2, 4($sp)
  sw $t4, 8($sp)
  sw $ra, 12($sp)
  
  jal verifica_andar
  
  lw $ra, 12($sp)
  lw $t4, 8($sp)
  lw $s2, 4($sp)
  lw $t7, 0($sp)
  addi $sp, $sp, -16 
  
  beq $v0, -1, ap_n_encontrado
  move $t7, $v0
  j ap_insere
  
  ap_insere:  # se chegarmos aqui é porque o apartamento foi encontrado, agora vamos verificar se o ap pode receber mais uma pessoa
    
    addi $t7, $t7, 3 # tendo recebi o apartamento vamos vasculhar jogando para a 1 posição das pessoas
    addi $t5, $0, 0 # inicia meu contador de pessoas caso seja 5 o a paratamento está cheio
    j vaga
    
    vaga:  # inicia um loop que verifica vaga por vaga
      
      lb $t3, 0($t7)  # carrega 1  caracter de de cada nome para saber se aquele ap esta disponivel
      beq $t3, 0, vaga_disponivel  # pula para a area de escriata ja que a vaga esta disponivel
      addi $t7, $t7, 20  # pula para o proximo nome a verificar
      addi $t5, $t5, 1  # verifica se o total de pessoas daquele ap ja foi verificado
      beq $t5, 5, apt_cheio  # caso todos os possiveis locais para incerir pessoas foram preenchidos
      j vaga  # retorna ao loop

  vaga_disponivel:  # se chegarmos aqui é por que o nome pode ser incerido
    
    addi $a0, $t7, 0 # carrega em a0 o que devemos incerir no local do nome
    addi $a1, $t4, 0 # carrega o espaço a ser incerido
    addi $t9, $ra, 0 # salva a posição original do arquivo
    
    addi $sp, $sp, -4
    sw $ra, 0($sp)
            
    jal strcpy  # copia a string no novo local controlando o numero de caracteres par aque o mesmo não utrapasse 19
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra # ja que a função foi bem sucedida retorna ao inicio
    
    apt_cheio: # caso o apartamento esteja cheio retor na o erro 2
      addi $v0, $0, 2 # carrega 2 no retorno 
      jr $ra # acaba a função
      
    
#########################################################################################################################
          
remover_pessoa:  # deve receber em a0 o apartamento e em a1 o nome
  
  move $t1, $a1 # salva o nome da pessoa para utilização futura
  move $a1, $s2 # recebe a posição inicial do meu space
  move $t9, $a0  # salva o apartamento para utilização posterior
  
  # salva as variaveis utilizadas para evitar problemas 
  addi $sp, $sp, -12  # salva o espaço em memoria par asalvar os registradores
  sw $t9, 8($sp) # salvando o apartamento na memoria
  sw $t1, 4($sp)  # salvando o nome da pessoa
  sw $ra, 0($sp)  # salvando o registrador de onde estavamos no codigo
    
  jal verifica_andar
  
  
  # carregha todas os registradores usadas
  lw $ra, 0($sp)  # resgatando o registrador de onde estavamos no codigo
  lw $t1, 4($sp)  # resgatando o nome da pessoa
  lw $t9, 8($sp)  # resgatando o apartamento na memoria
  addi $sp, $sp, 12  # resgatando o espaço em memoria par asalvar os registradores
  
  beq $v0, -1, ap_n_encontrado  # verifica se o aptamento foi encontrado 
  addi $t2, $v0, 3  # adicionando 3 no ponteiro ele ira ate a posição do primeiro nome dos moradores
  addi $t3, $0, 1 # inicia um contador par asaber quantas pessoas foramverificadas
  j  remover_pessoa_ac  # se chegar aqui o anadar foi encontrado
  
  remover_pessoa_ac: #  inicializa a possivel remoção do morador
    move $a0, $t2  # adiciona ao argumento a0 a posição que ele deve utilizar na busca peno nome usado no comando
    move $a1,  $t1  # adiciona ao argumento a1 a posição que ele deve utilizar na busca
    
    # salva as variaveis utilizadas para evitar problemas 
    addi $sp, $sp, -20  # libera espaço na memoria para salvar os registradores antes da função
    sw $t9, 16($sp)  # armazena o apartamento para verificação futura
    sw $t1, 12($sp)  # armazena o registrador com a posição do nome na função ne memoria
    sw $t2, 8($sp)  # armazena o registrador com a posição do nome nos apartamentos
    sw $t3, 4($sp)  # armazena o registrador com a contagem de pessoas
    sw $ra, 0($sp)  # salvando o registrador de onde estavamos no codigo
    
    jal strcmp  # carregar a string a ser removida em a0 e em a1 o ponteiro no momento 
    
    #  recarrega as variaveis pos função
    lw $ra, 0($sp) # recebendo o registrador de onde estavamos no codigo
    lw $t3, 4($sp)  # recebendo o registrador com a contagem de pessoas
    lw $t2, 8($sp)  # recebendo o registrador com a posição do nome nos apartamentos
    lw $t1, 12($sp)  # recebendo o registrador com a posição do nome na função ne memoria
    lw $t9, 16($sp)  # resgatando o espaço em memoria par asalvar os registradores
    addi $sp, $sp, 20  # recebendo o espaço na memoria para salvar os registradores antes da função
    
    addi $t3, $t3, 1  # adiciona um ao contador de pessoas verificadas
    beq $v0, 0, pessoa_encontrada  # verifica se o nome a ser removido é esse
    addi $t2, $t2, 20 # pula para o proximo nome
    beq $t3, 5, pessoa_n_enc  #  caso a pessoa não seja encontrada
    j remover_pessoa_ac  # retorna ao loop

  pessoa_n_enc:
    addi $v0, $0, 1 # carrega 1 em v0
    jr $ra # encerra a função

  pessoa_encontrada:  # função que vai remover a pessoa em si
    addi $t1,$0, 0  #  adiciona 0 a t1 para que o mesmo substitua o nome da pessoa
    lb $t3, 0($t2)  # carrega o qeu esta na memoria para verifica rse o mesmo ja foi removido
    beq $t3, 0, apagado  # verifica se ele foi removido | caso seja va para apagado
    sb $t1, 0($t2)  #  remove o caracter em questão
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
    jr $ra # encerra a função
  
######################################################################################################################### 

leArquivo:

  #Abre arquivo para ler

	li $v0, 13			#abrir arquivo
	la $a0, localArquivo 		#informa endereÃ§o
	li $a1, 0 			#informa parametro leitura
	syscall 			#descritor pra $v0

        move $s1, $v0 			#copia o descritor de $v0 para $s0
	move $a0, $s1 			#copia o descritor de $s0 para $a0

  #De fato lÃª
	
	li $v0, 14 			#ler conteudo do arquivo referenciado por $a0
	la $a1, apt_space 	#armazenamento
	li $a2, 7480 			#tamanho do armazenamento
	syscall 			#leitura realizada do conteudo guardado em $a1

  #Fecha o arquivo

        li $v0, 16 			#fecha arquivo
	move $a0, $s1 			#copia para o parametro $a0 o descritor guarado em $s0
	syscall 			#executa função

	jr $ra	

#########################################################################################################################

strcpy: #espaço na memoria em a0, a1 a mensagema ser copiada

  addi $t2, $a0, 0  # adiciona os endereços a t2
  addi $t3, $a1, 0  # adiciona os endereços as t3
  addi $t4, $0, 0  # inicia um contador de caracteraes (19)
  
  loop:
  
    lb $t1, 0($t3) # carrega em t1 o conteudo de a0 no momento
    addi $t3, $t3, 1  # pula para a proxima casa de a0
    
    sb $t1, 0($t2) # carrega em t2 o conteudo de a1 no momento
    addi $t2, $t2, 1  # pula para a proxima casa de a0
    addi $t4, $t4, 1
    beq $t4, 19, fim_str
    bne $t0, $t1, loop # cetificace de que a string ainda não acabou
  
  addi $t1, $0, 0 #carrega o valor a ser incerido na copia "/0"
  sb $t1, 0($t2) # valor a ser incerido na copia "/0"
  addi $v0, $a0, 0  # retorna a função em v0
  jr $ra  # rotorna ao fluxo normal
  
  fim_str:
  addi $t1, $0, 0 #carrega o valor a ser incerido na copia "/0"
  sb $t1, 0($t2) # valor a ser incerido na copia "/0"
  addi $v0, $a0, 0  # retorna a função em v0
  jr $ra  # rotorna ao fluxo normal

#########################################################################################################################

strcmp:  # inicia a função comparador
    
    loop_principal: # inicia o loop principal da função
      
      lb $t0, 0($a0)  # carrega o valor a partir de a0 a ser avaliado 
      addi $a0, $a0, 1  # incrementa para que a proxima letra seja pega.
      
      lb $t1, 0($a1)  # carrega o valor a partir de a1 a ser avaliado 
      addi $a1, $a1, 1  # incrementa para que a proxima letra seja pega.
      
      bne $t0, $t1, final_diferente  #  verifica se os valores analizados são diferentes
      
      beq $t0, $0, filtro_1  #  verifica se os dois valores são iguais
      beq $t1, $0, final_diferente  #  chegando aqui verifica-se se a outra string tenha acabado ja que se a mesma acabou ambas são diferentes
      
      j loop_principal  #  rotorna ao loop principal caso nenhum criterio de parada seja atendido
      
      filtro_1:  #  verifica se os resultados anlizados são iguais a 0, ja que se é 0 significa que ambas as strings são iguais
        beq $t1, $0, final_igual  # caso sejão iguais va poara final_igual
        j final_diferente  # sendo diferente, va para final_diferente
      
      final_diferente:  # para os casos de 1 - uma string encerrar antes da outra, 2 - o primeiro valor diferente entre um e outro
      
        sub $v0, $t0, $t1 # Realiza uma subtração entre o ultimo valor de a0 e o ultimo valor de a1, para atender as diretrizes da função, alem de devolver o resultado em v0.
        jr $ra #  retorna a execução normal do programa 
        
      final_igual:  # para o caso de as 2 strings serem iguais 
         
         addi $v0, $0, 0  # o retorno em v0 deve ser 0
         jr $ra  #  retorna a execução normal do programa 

#########################################################################################################################

verifica_andar: # Em a0 deve ser disposto o andara ser verificado
  
  move $a1, $s2
  move $t6, $a1  # salva a posição inicial de a1
  addi $t7, $0, 0  # salva em t1 0
  addi $t7, $a1, 7480  # t7 marca o fim doa aps
  move $t5, $a0  # armazena o ponteiro do apartamento incerido 
  
  verificador_andara: 
    move $a0, $t5 # passa o ponteiro do apartamento incerido 
    addi $a1, $t6, 0  # carrega a  posiçaoo do espaço disponivel em vigor para ser comparada
    addi $t8, $ra, 0  # salva onde estava no codigo
    jal strcmp  # verifica se as strings são iguais (caso sejam: o apartamento foi achado)
    addi $ra, $t8, 0 # recupera onde estava no codigo
    beq $v0, 0, ap_enc  # confere se as strings são iguais  se sim envia para a inserção

    addi $t6, $t6, 187 # pula para o numero do proximo apartamento
    beq $t6, $t7, apt_n_achado  # verifica se a contagem ja cobriu todos os apartamentos
    j verificador_andara  # retorna ao inicio do loop
    
  ap_enc:  # retorna a posição que dio andar
    move $v0, $t6  #  move para v0 o retorno
    jr $ra  # retorna para a execução do arquivo
    
  apt_n_achado: # caso o ap n seja achado retorna -1
    addi $v0, $0, -1   # move para v0 o retorno
    jr $ra # retorna para a execução do arquivo
    
ap_n_encontrado:  # devolve 1 em v0 pq o ap não foi encontrado
    addi $v0, $0, 1 # carrega 1 em v0
    jr $ra # encerra a função

#########################################################################################################################

verifica_ap: # Percorre um apartamento verificando se está vazio - O número do ap deve ser informado em a0
  addi $sp, $sp, -4  # libera espaço na memoria para salvar os registradores antes da função
  sw $ra, 0($sp)  # salvando o registrador de onde estavamos no codigo
  
  jal verifica_andar
  
  lw $ra, 0($sp) # recebendo o registrador de onde estavamos no codigo
  addi $sp, $sp, 4  # recebendo o espaço na memoria para salvar os registradores antes da função
  
  addi $t2, $v0, 3 # Carrega a posição da primeira pessoa do AP
  addi $t4, $0, 0 # inicia meu contador de pessoas caso seja 5 o a paratamento está cheio
  
  
  vaga_ap:
    lb $t3, 0($t2)  # carrega 1 posição de cada nome para saber se aquele ap esta disponivel
    bne $t3, 0, apt_ocupado  # pula para a area de escriata ja que a vaga esta disponivel
    addi $t2, $t2, 20  # pula para o proximo nome a verificar
    addi $t4, $t4, 1  # Incrementa o contador de pessoas verificadas
    beq $t4, 5, apt_vazio  # caso todos os possiveis locais para incerir pessoas foram preenchidos
    j vaga_ap # Reinicia o loop
      
      
  apt_ocupado: # Caso exista uma pessoa no AP, retorna a função.
    addi $v0, $0, 1 # Carrega 1 em v0 
    jr $ra # Retorna a função
    
  apt_vazio: # Caso o apartamento esteja vazio, retorna a função.
    addi $v0, $0, 2 # Carrega 2 em v0 
    jr $ra # Retorna a função
    
#########################################################################################################################

esvasia_apt:  # recebe em a0 o endereço do apt
  move $a1, $s2
  addi $sp, $sp, -4  # armazena o ra para utilização futura
  sw $ra, 0($sp)  # armazena o ra para utilização futura
  
  jal verifica_andar
  
  lw $ra, 0($sp)  # recupera o ra para utilização futura
  addi $sp, $sp, 4 # recupera o ra para utilização futura
  
  beq $v0, -1, ap_n_encontrado  # verifica se o apartamento não foi encontrado
  addi $t3, $v0, 187  #  gera o fim da lisat do aparatamento
  addi $t1, $v0, 3  # vai ate o inicio do arrey a ser testado
  addi $t2, $0, 0  # inicia o contrador de caracteres
  
  removedor: # remove todo o apartamento em si
    sb $t2, 0($t1)  # salva /0 na memoria
    addi $t1, $t1, 1 # adiciona 1 ao contador
    bne $t1, $t3, removedor  # verifica o fim da remoção
    jr $ra  #  velta para o fim da dunção

#########################################################################################################################
fim: # finaliza o codigo
  addi $v0, $0, 10
  syscall

verificador_info_geral:  # é responsavel por realizar a contagem das apartamentos com pessoas e sem pessoas
  move $t1, $s2  #  pega o inicializador, como ele sempre esta em s2   
  addi $t2, $0, 0   #  inicia os contadores
  addi $t3, $0, 0  #  inicia os conatdores
  
  #  os contadores estão ($t2 com a contagem dos aps cheios e $t3 com os aps sem pessoas)
  
  loop_apts:  # loop principal que passa de ap em ap
    move $a0, $t1  #  move a ponta do apartamento a ser verificado
    addi $t1, $t1, 187  # pula para o proximo ap
    
    addi $sp, $sp, -16  #  libera o espaço na memoria para evitar problemas com conflitos
    sw $t1, 0($sp)  #  qurda t1 contagem de aps
    sw $t2, 4($sp)  #  qurda t2 contagem de aps vasios
    sw $t3, 8($sp)  #  qurda t3 contagem de aps cheios
    sw $ra, 12($sp)  #  quarda a posição no pc
    
    jal verifica_ap  # verifica se o ap esta cheio
    
    lw $ra, 12($sp)  #  recupera a posição no pc
    lw $t3, 8($sp)  #  recupera t3 contagem de aps cheios
    lw $t2, 4($sp)  #  recupera t2 contagem de aps vasios
    lw $t1, 0($sp)  #  recupera t1 contagem de aps
    addi $sp, $sp, 16  #  libera o espaço na memoria para evitar problemas com conflitos
    
    
    
    beq $v0, 2, apt_va  #  verifica se o apt esta cheio ou não
    beq $v0, 1, apt_ch  #  verifica se o apt esta cheio ou não
    
    verificador_fim_aps: # verifica se a contagem chegou ao fim
      add $t4, $t2, $t3  #  soma os contadores para fer se juntos chegam a 40
      beq $t4, 40, apts_verificados  # verifica a contagem
      j loop_apts  # caso não estejam retorna ao loop

    apt_ch:  # caso esteja cheio soma 1 em  t2
      addi $t2, $t2, 1  # caso esteja cheio soma 1 em  t2
      j verificador_fim_aps #  varifica se acabarao os aps
      
    apt_va:  # caso não esteja cheio soma 1 em  t3
      addi $t3, $t3, 1  # caso não esteja cheio soma 1 em  t3
      j verificador_fim_aps #  varifica se acabarao os aps
      
    apts_verificados:  # verifica se todos os apartamentos estão  verificados
      move $v0, $t2  #  caso sim coloca em v0 os aps cheios 
      move $v1, $t3  #  caso sim coloca em v1 os não cheios
      jr $ra  # retorna a antes da função
