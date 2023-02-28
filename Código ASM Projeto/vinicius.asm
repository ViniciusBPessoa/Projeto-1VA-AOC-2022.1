.data

  msg_falha_1: .asciiz "Falha: AP invalido"  
  apt_array: # separa o espaço de um arrei na memoria  
  	.align 0  # diz que esse arrei deve 
  	.space 7320  #  183 por entidade
  	
  apt_space: .space 7320  #  espaços para verificação


  nome: .asciiz "Vinicius B"  
  ap: .word 1  

.text

main:
  
  addi $t2, $0, 0  
  
  la $s0, apt_space
  la $a0, ap
  la $a1, nome
  
  sb $t1, apt_array($a0)
  
  jal incerirPessoa
  
  j fim

incerirPessoa:  # vou considerar que o valor de $a0 apartamento e $a1 esta com o nome a ser incerrido
  
  addi $t0 , $0, 0  #valor da primeira linha a buscar, alem de ser o ponteiro no arquiivo principal
  addi $t1, $0, 7320 #maior valor possivel  indicando que aquele ap não foi encontrado
  la $t4, msg_falha_1  #carregha a primeira msg de falha

  verificador:
    lb $t3, apt_array($t0)  #carrega a primeira posição do arrey e nas proximas interaçoes apenas os numeros de apartamentos
    beq $a0, $t3, sair_verificador_andar  # verifica se aquele apartamento foi encontrado
    addi $t0, $t0, 183 # pula para o numero do proximo apartamento
    beq $t3, $t1, ap_n_encontrado  # verifica se a contagem ja cobriu todos os apartamentos
    j verificador  # retorna ao inicio do loop

  ap_n_encontrado:  # devou a resposta se o qp estiver cheio
    addi $a0, $t4, 0  # adiciona a resposta a impressoira
    addi $t9, $ra, 0  # salva a posição do arquivo para voutarmos as posição inicial
    jal imprime_string # vai ate a area de imprimir strings
    addi $ra, $t9, 0  # pega a posição original no arquivo
    jr $ra #retorna para antes da função
    
  sair_verificador_andar:  # se chegarmos aqui é porque o apartamento foi encontrado
    
    addi $t2, $0, 0  # seta em t2 
    addi $t0, $t0, 1  # seta em t0  o ponteiro que vai vasculhar o arrey como +1 para acessar a parte de nomes
    addi $t4, $0, 1  # seta em t4 o contador de nomes para verificar se todos os espaços de nomes foram preenchidos
    
    vaga:
      
      lb $t3, apt_array($t0)  # carrega 1  posição de de cada nome para saber se aquele ap esta disponivel
      beq $t3, $t2, vaga_disponivel  # pula para a area de escriata ja que a vaga esta disponivel
      addi $t0, $t0, 20  # pula para o proximo nome a verificar
      addi $t4, $t4, 1  # verifica se o total de pessoas daquele ap ja foi verificado
      beq $t4, 5, apt_cheio  # caso todos os possiveis locais para incerir pessoas foi preenchido
      j vaga  # retorna ao loop

  vaga_disponivel:
  
    addi $t6, $a0, 0  # adiciona os endereços a t6
    addi $t4, $0, 1  # carrega o valor maximo de caracters na string que pode ser escrito
    
    loop: # loop de esscrita
      lb $t6, 0($t2)  # carrega o valor a ser escrito
      addi $t6, $t6, 1 # acresce o valor para coletar o proximo item
      
      sb $t6, apt_array($t0)  # escreve o caractere desejado
      addi $t0, $t0, 1 # acresce 1 para ascessar o proximo valor a ser esdcrito
      
      
      
      beq $t4, 19, fim_funk  # caso a escrita tenha finalizato pila para o fim da função
      addi $t4, $t4, 1 # almenta um para verificar se o limite foi atingido
      
      bne $t6, 0, loop  # caso o nome ja tenha cido completamente escrito encerra a função
    
    fim_funk:
      addi $t6, $0, 0  # escreve o caractere "/0"
      sb $t6, apt_array($t0) # escreve o caractere "/0"
      jr $ra # sai da função
    
    apt_cheio:
      addi $a0, $t4, 0  # adiciona a resposta a impressoira
      addi $t9, $ra, 0  # salva a posição do arquivo para voutarmos as posição inicial
      jal imprime_string # vai ate a area de imprimir strings
      addi $ra, $t9, 0  # pega a posição original no arquivo
      jr $ra #retorna para antes da função
     
imprime_string:					#Recebe a string a ser lida em $a0
    addi $v0, $0, 4				#Chama a função imprimir string
    syscall						#Executa a função
    jr $ra						#Retorna pra quem chamou o procedimento
    
fim: # finaliza o codigo
  addi $v0, $0,  10   # Armazena o código da syscall para finalizar o codigo
  syscall
  
