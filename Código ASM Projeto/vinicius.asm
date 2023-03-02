.data
  
  nome: .asciiz "Vinicius BezerraPessoaDasil"  
  ap: .asciiz "40"

  apt_space: .space 7480  #  espaï¿½os para verificaï¿½ï¿½o
  localArquivo: .asciiz "C:/aps.txt"

.text

main:
  
  jal leArquivo
  addi $s2, $a1, 0
  la $a0, ap
  la $a1, nome

  jal incerirPessoa
  
  j fim



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

  ap_n_encontrado:  # devolve 1 em v0 pq o ap não foi encontrado
    addi $v0, $0, 1 # carrega 1 em v0
    jr $ra # encerra a função
    
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
         
verifica_andar: # Em a0 deve ser disposto o andara ser verificado e em a1 o ponteiro para o inicio do space de andares
  
  move $t0, $a0 
  move $t1, $a1
  addi $t7, $0, 0
  addi $t7, $a1, 7480
  
  verificador_andara: 
    addi $a1, $t1, 0  # carrega a  posi??o do espa?o disponivel em vigor para ser comparada
    addi $t9, $ra, 0  # salva onde estava no codigo
    jal strcmp  # verifica se as strings s?o iguais (caso sejam: o apartamento foi achado)
    addi $ra, $t9, 0 # recupera onde estava no codigo
    beq $v0, 0, ap_enc  # confere se as strings s?o iguais  se sim envia para a inser??o

    addi $t1, $t1, 187 # pula para o numero do proximo apartamento
    beq $t1, $t7, apt_n_achado  # verifica se a contagem ja cobriu todos os apartamentos
    j verificador_andara  # retorna ao inicio do loop
  
  ap_enc:
    move $v0, $t1
    jr $ra
    
  apt_n_achado:
    addi $v0, $0, -1
    jr $ra
  
fim: # finaliza o codigo
  addi $v0, $0, 10
  syscall
