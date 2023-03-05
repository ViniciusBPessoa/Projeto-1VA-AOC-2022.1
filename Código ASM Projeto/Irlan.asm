.data
  
  nome: .asciiz "Vinicius BezerraPessoaDasil"  
  ap: .asciiz "01"
  modelo: .asciiz "Kawazaki"
  modeloT: .asciiz "asdas"
  cor: .asciiz "Preto"
  tipo: .asciiz "m"

  apt_space: .space 7480  #  espaços para verificação
  localArquivo: .asciiz "C:/Users/Irlan/Desktop/aps.txt"

.text

main:
  
  jal leArquivo
  
  addi $s2, $a1, 0		#$s2 armazena todo o conteudo do arquivo
  
  la $a0, ap
  la $a1, tipo
  la $a2, modelo
  la $a3, cor
  
  #jal inserirAuto
  jal removerAuto
  
  jal escreveArquivo
  
  j fim

#######################################################################################################################

incerirPessoa:  # vou considerar que o valor de $a0 apartamento e $a1 esta com o nome a ser incerrido: em $s2 esta a lista de itens em $s2 estara a posição inicial dos APs
# os possiveis erros estão em $v0 sendo eles 1 ou 2, 1 = apartamento não encontrado
  
  addi $t7 , $s2, 0  # carrega a primeira posição do espaço disponivel para o sistema de apartamneto
  addi $t2, $t7, 7480 # maior valor possivel  a ser escrito no sistema
  addi $t4, $a1, 0  #  salva o que esta em a1, para utilizar em algumas outras funçoes
  
  verificador_andar: 
    addi $a1, $t7, 0  # carrega a  posição do espaço disponivel em vigor para ser comparada
    addi $t9, $ra, 0  # salva onde estava no codigo
    addi $t8, $a0, 0  # salva a posição inicial do meu ap a ser comparado
    jal strcmp  # verifica se as strings são iguais (caso sejam: o apartamento foi achado)
    addi $ra, $t9, 0 # recupera onde estava no codigo 
    addi $a0, $t8, 0 # recupera a posição inicial do meu ap a ser comparado
    beq $v0, 0, ap_insere  # confere se as strings são iguais  se sim envia para a inserção

    addi $t7, $t7, 187 # pula para o numero do proximo apartamento
    beq $t2, $t7, ap_n_encontrado  # verifica se a contagem ja cobriu todos os apartamentos
    j verificador_andar  # retorna ao inicio do loop
    
  ap_insere:  # se chegarmos aqui é porque o apartamento foi encontrado, agora vamos verificar se o ap pode receber mais uma pessoa
    
    addi $t7, $t7, 3 # tendo recebi o apartamento vamos vasculhar jogando para a 1 posição das pessoas
    addi $t5, $0, 0 # inicia meu contador de pessoas caso seja 5 o a paratamento está cheio
    
    vaga:  # inicia um loop que verifica vaga por vaga
      
      lb $t3, 0($t7)  # carrega 1  ção de de cada nome para saber se aquele ap esta disponivel
      beq $t3, 0, vaga_disponivel  # pula para a area de escriata ja que a vaga esta disponivel
      addi $t7, $t7, 20  # pula para o proximo nome a verificar
      addi $t5, $t5, 1  # verifica se o total de pessoas daquele ap ja foi verificado
      beq $t5, 5, apt_cheio  # caso todos os possiveis locais para incerir pessoas foram preenchidos
      j vaga  # retorna ao loop

  vaga_disponivel:  # se chegarmos aqui é por que o nome pode ser incerido
    
    addi $a0, $t7, 0 # carrega em a0 o que devemos incerir no local do nome
    addi $a1, $t4, 0 # carrega o espaço a ser incerido
    addi $t9, $ra, 0 # salva a posição original do arquivo
    jal strcpy  # copia a string no novo local controlando o numero de caracteres par aque o mesmo não utrapasse 19
    addi $ra, $t9, 0 # recupera a posição original do arquivo
    jr $ra # ja que a função foi bem sucedida retorna ao inicio
    
    apt_cheio: # caso o apartamento esteja cheio retor na o erro 2
      addi $v0, $0, 2 # carrega 2 no retorno 
      jr $ra # acaba a função
      
#######################################################################################################################
      
inserirAuto: #$a0 AP - $a1 TIPO AUTO (C OU M) - $a2 MODELO - $a3 COR
    addi $t0, $s2, 0			#Posicao inicial do arquivo
    
    addi $t1, $a0, 0			#Carrega AP em $t1
    addi $t2, $a1, 0			#Carrega TIPO em $t2
    addi $t3, $a2, 0			#Carrega MODELO em $t3
    addi $t4, $a3, 0			#Carrega COR em $t4
    
    move $a0, $t1			#Parametro $a0 = ap
    move $a1, $t0			#Parametro $a1 = posição inicial
    
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal verifica_andar			#Recebe andar em $a0 e posição inicial em $a1
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    bne $v0, -1, verificarVaga		#Caso o andar exista, verifica se há vaga
    
    #Retorna mensagem “Falha: AP invalido
    jr $ra				#Retorna a quem chamou inserirAuto
    
    verificarVaga:
    	add $t5, $v0, 103		#Guarda em $t5 a posição do andar($v0) junto a posição do primeiro auto($t0)
    	
    	lb $t7, 0($t5)			#Pega o tipo (se houver) do auto na vaga, caso nao houver $t7 = 0
    	lb $t8, 0($t2)			#Pega o tipo do auto passado
    	
    	beq $t8, 99,  autoValidado
    	beq $t8, 109, autoValidado
    	
    	#Retornar mensagem “Falha: tipo invalido”
    	jr $ra
    	
    	autoValidado:
    	    
    	    beq $t7, 99,  cancelaInsc	#Caso houver 1 carro na vaga, não permitir mais inserção de auto
    	    beq $t7, 109, insereMoto	#Caso houver 1 moto na vaga, permitir inserção de outra moto
    	    beq $t7, 0,   insereAuto	#Caso não huver nenhum auto, permitir inserção de qualquer auto
    	
    	insereAuto:
    	    move $a0, $t5		#Parametro em $a0 = posição a ser inserida
    	    move $a1, $t2		#Parametro em $a1 = tipo do auto
    	    move $a2, $t3		#Parametro em $a2 = modelo do auto
    	    move $a3, $t4		#Parametro em $a3 = cor do auto
    	    
    	    addi $sp, $sp, -4
    	    sw $ra, 0($sp)
    	    
    	    jal strcpy			
    	    
    	    addi $a0, $a0, 2		#Pula para a posição da vaga em que insere o modelo
    	    move $a1, $a2		#Parametro em $a1 = modelo do auto
    	    jal strcpy			
    	    
    	    addi $a0, $a0, 20		#Pula para a posição da vaga em que insere a cor
    	    move $a1, $a3		#Parametro em $a1 = cor do auto
    	    jal strcpy		
    	    
    	    lw $ra, 0($sp)
    	    addi $sp, $sp, 4	
    	    
    	    jr $ra
    	
    	insereMoto:
    	    addi $t8, $t5, 42		#Carrega em $t8 a posição da próxima vaga
    	    lb $t9, 0($t8)
    	    beq $t8, 109, cancelaInsc	#Caso houver uma segunda moto, não permitir a inserção de outra moto
    	    
    	    move $a0, $t8		#Parametro em $a0 = posição a ser inserida
    	    move $a1, $t2		#Parametro em $a1 = tipo do auto
    	    move $a2, $t3		#Parametro em $a2 = modelo do auto
    	    move $a3, $t4		#Parametro em $a3 = cor do auto
    	    
    	    addi $sp, $sp, -4
    	    sw $ra, 0($sp)
    	    
    	    jal strcpy			
    	    
    	    addi $a0, $a0, 2		#Pula para a posição da vaga em que insere o modelo
    	    move $a1, $a2		#Parametro em $a1 = modelo do auto
    	    jal strcpy			
    	    
    	    addi $a0, $a0, 20		#Pula para a posição da vaga em que insere a cor
    	    move $a1, $a3		#Parametro em $a1 = cor do auto
    	    jal strcpy			
    	    
    	    lw $ra, 0($sp)
    	    addi $sp, $sp, 4
    	    
    	    jr $ra
    	    
    	cancelaInsc:
    	   #Retornar mensagem “Falha: AP com numero max de automóveis"
    	   jr $ra
    	    
#######################################################################################################################

removerAuto: #a0 AP - a1 tipo - a2 modelo - a3 cor
    addi $t0, $s2, 0			#Posicao inicial dos auto

    addi $t1, $a0, 0			#Carrega AP em $t1
    addi $t2, $a2, 0			#Carrega MODELO em $t2
    addi $t6, $a1, 0			#Carrega TIPO em $t2
    addi $t7, $a3, 0			#Carrega COR em $t2
    
    move $a0, $t1			#Parametro $a0 = ap
    move $a1, $t0			#Parametro $a1 = posição inicial
    
    addi $sp, $sp, -24
    sw $t7, 20($sp) 
    sw $t6, 16($sp) 
    sw $t2, 12($sp)
    sw $t1, 8($sp) 
    sw $t0, 4($sp)
    sw $ra, 0($sp)
    jal verifica_andar			#Recebe andar em $a0 e posição inicial em $a1
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp) 
    lw $t2, 12($sp)
    lw $t6, 16($sp)
    lw $t7, 20($sp)
    addi $sp, $sp, 24
    
    
    addi $t0, $v0, 0			#Acessa apartamento n recebido por verifica_andar
    
    bne $v0, -1, buscarAuto		#Caso o andar exista, verifica se há vaga
    
    #Retorna mensagem “Falha: AP invalido"
    jr $ra				#Retorna a quem chamou inserirAuto
    
    buscarAuto:
    	addi $t3, $t0, 105 		#Pula para o modelo de auto do apartamento n
    	
    	move $a0, $t2			#Parametro para strcmp passando o modelo dado
    	move $a1, $t3			#Parametro para strcmp passando o modelo em vigor
    	move $a2, $t6			#Parametro para strcmp passando o tipo dado
    	move $a3, $t7			#Parametro para strcmp passando a cor dada
    	
    	addi $sp, $sp, -4
    	sw   $ra, 0($sp)
    	jal checaAuto
    	lw   $ra, 0($sp)
    	addi $sp, $sp, 4
    	
    	bne $s7, 0, autoInvalido 	#Checa se auto com modelo passado existe
    	bne $s6, 0, autoInvalido  	#Checa se auto com tipo passado existe
    	bne $s5, 0, autoInvalido  	#Checa se auto com cor passada existe
    	
        move $t6, $t3			#Copia a posição do modelo atual para t6
    	beq  $s7, $0, removeModelo	#Verefica se o auto na posicao é o auto procuradom, se sim, remova
    	
    	
    	addi $t3, $t3, 42		#Pula para prox modelo de auto do apartamento n
        
    	move $a0, $t2			#Parametro para strcmp passando o modelo dado
    	move $a1, $t3			#Parametro para strcmp passando o modelo em vigor
    	move $a2, $t1			#Parametro para strcmp passando o tipo em vigor
    	move $a3, $t4			#Parametro para strcmp passando a cor em vigor
        	
    	addi $sp, $sp, -4
    	sw   $ra, 0($sp)
    	jal checaAuto
    	lw   $ra, 0($sp)
    	addi $sp, $sp, 4
    	
    	bne $s7, 0, autoInvalido 	#Checa se auto com modelo passado existe
    	bne $s6, 0, autoInvalido  	#Checa se auto com tipo passado existe
    	bne $s5, 0, autoInvalido  	#Checa se auto com cor passada existe
    	
    	move $t6, $t3			#Copia a posição do modelo atual para t6
    	beq  $s7, $0, removeModelo	#Verefica se o auto na posicao é o auto procuradom, se sim, remova
    	
    	#Retorna mensagem "Falha: automóvel nao encontrado"
    	jr $ra
    	
    checaAuto:
    	addi $sp, $sp, -20
    	sw   $t0, 16($sp)
    	sw   $t1, 12($sp)
    	sw   $t2, 8($sp)
    	sw   $t3, 4($sp)
    	sw   $ra, 0($sp)
    	
    	jal strcmp  			#Compara as strings de modelo
    	move $s7, $v0			#Salva resultado da função em $s7
    	
    	move $a0, $a2			#Parametro carregando o tipo do auto
    	addi $a1, $t3, -2		#Pega a pocição do tipo
    	jal strcmp  			#Compara o caracter de tipo	
    	move $s6, $v0			#Salva resultado da função em $s6
    	
    	addi $a1, $t3, 20		#Pega a pocição da cor
    	move $a0, $a3			#Parametro carregando a cor do auto
    	jal strcmp  			#Compara o caracter de cor
    	move $s5, $v0			#Salva resultado da função em $s5	
    	
    	lw   $ra, 0($sp)
    	lw   $t3, 4($sp)
    	lw   $t2, 8($sp)	
    	lw   $t1, 12($sp)
    	lw   $t0, 16($sp)
    	addi $sp, $sp, 20
    	
    	jr $ra
    	
    autoInvalido:
    	#Retornar mensagem auto especificado n existe
        jr $ra
    	
    removeModelo:
    	lb   $t4, 0($t6)		#Pega caractere atual em modelo
    	beq  $t4, 0,  removeTipo	#Checa se a remoção ja foi realizada e encerra a função 
    	addi $t5, $0, 0			#Instancia o valor 0, a ser substuido a cada caractere em modelo
    	sb   $t5, 0($t6)		#Substitui o caractere atual em modelo por 0
    	addi $t6, $t6, 1		#Pula para o próximo caractere
    	j removeModelo			#Recursao
    	
    removeTipo:
    	move $t6, $t3			#Pega novamente o primeiro byte da posicao de modelo
    	addi $t6, $t6, -2 		#Passa ponteiro pra posição de tipo
    removeTipoAux:
    	lb   $t4, 0($t6)		#Pega caractere atual em tipo
    	beq  $t4, 0, removeCor		#Checa se a remoção ja foi realizada e encerra a função 
    	addi $t5, $0, 0			#Instancia o valor 0, a ser substuido a cada caractere em tipo
    	sb   $t5, 0($t6)		#Substitui o caractere atual em modelo por 0
    	addi $t6, $t6, 1		#Pula para o próximo caractere
    	j removeTipoAux			#Recursao
    	
    removeCor:
    	move $t6, $t3			#Pega novamente o primeiro byte da posicao de modelo
    	addi $t6, $t6, 20		#Passa ponteiro pra posição de tipo
    removeCorAux:
    	lb   $t4, 0($t6)		#Pega caractere atual em tipo
    	beq  $t4, 0, autoRemovido	#Checa se a remoção ja foi realizada e encerra a função 
    	addi $t5, $0, 0			#Instancia o valor 0, a ser substuido a cada caractere em tipo
    	sb   $t5, 0($t6)		#Substitui o caractere atual em modelo por 0
    	addi $t6, $t6, 1		#Pula para o próximo caractere
    	j removeCorAux			#Recursao
    
    autoRemovido:
    	jr $ra				#Sai da função
    	
#######################################################################################################################
    
leArquivo:

  #Abre arquivo para ler

	li $v0, 13			#abrir arquivo
	la $a0, localArquivo 		#informa endereÃ§o
	li $a1, 0 			#informa parametro leitura
	syscall 			#descritor pra $v0

        move $s1, $v0 			#copia o descritor de $v0 para $s0
	move $a0, $s1 			#copia o descritor de $s0 para $a0

  #De fato lê
	
	li $v0, 14 			#ler conteudo do arquivo referenciado por $a0
	la $a1, apt_space 		#armazenamento
	li $a2, 7480 			#tamanho do armazenamento
	syscall 			#leitura realizada do conteudo guardado em $a1

  #Fecha o arquivo

  	li $v0, 16 			#fecha arquivo
	move $a0, $s1 			#copia para o parametro $a0 o descritor guarado em $s0
	syscall 			#executa função

	jr $ra	
	
######################################################################################################################
	
escreveArquivo:

	#Abre arquivo para escrever
	
	li $v0, 13			#abrir arquivo
	la $a0, localArquivo 		#informa endereço
	li $a1, 1			#informa parametro escrita
	syscall 			#descritor pra $v0
	
	#De fato escreve
	
	li $v0, 15			#escreve conteudo no arquivo referenciado em $a0
	move $a0, $s1 			#copia para o parametro $a0 o descritor guarado em $s0
	la $a1, apt_space 		#Conteudo a ser escrito
	li $a2, 7480			#Quantidade de caracteres a em escritos
	syscall				#executa a função
		
	li $v0, 16 			#fecha arquivo
	move $a0, $s1 			#copia para o parametro $a0 o descritor guarado em $s0
	syscall 			#executa função

	jr $ra	
	
######################################################################################################################	

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

######################################################################################################################

strcmp:  # inicia a funï¿½ï¿½o comparador
    
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
  
######################################################################################################################
                       
verifica_andar: # Em a0 deve ser disposto o andara ser verificado e em a1 o ponteiro para o inicio do space de andares
  
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
  
######################################################################################################################

fim: # finaliza o codigo
  addi $v0, $0, 10
  syscall