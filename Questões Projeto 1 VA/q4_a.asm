.data
  
  mensagem1: .asciiz "mens" # Carrega a messagem a ser copiada
  mensagem2: .asciiz "mens" # Carrega a messagem a ser copiada
  espaco: .space 4 # Carrega o espa�o na memora para o qual a copia ir�
  espaco_2: .space 200 # Carrega o espa�o na memora para o qual a copia ir�
  
.text
  
main: 
  
  la $a0, espaco # separa o espa�o na memoria em a0
  la $a1, mensagem1 #carrega em a1 a mensagema ser copiada
  
  jal strcpy # pula para a fun��o
  la $a0, espaco_2 # separa o espa�o na memoria em a0
  jal strcpy # pula para a fun��o
  
  addi $a0, $v0, 0 # adiciona o retorno a0 o retorno para testar a resposta
  jal imprime_string  # imprime o teste
  
  j fim # pula para o fim do programa
  
strcpy:

  addi $t2, $a0, 0  # adiciona os endere�os a t2
  addi $t3, $a1, 0  # adiciona os endere�os as t3
  
  loop:
  
    lb $t1, 0($t3) # carrega em t1 o conteudo de a0 no momento
    addi $t3, $t3, 1  # pula para a proxima casa de a0
    
    sb $t1, 0($t2) # carrega em t2 o conteudo de a1 no momento
    addi $t2, $t2, 1  # pula para a proxima casa de a0
  
    bne $t0, $t1, loop # cetificace de que a string ainda n�o acabou
  
  addi $t1, $0, 0 #carrega o valor a ser incerido na copia "/0"
  sb $t1, 0($t2) # valor a ser incerido na copia "/0"
  addi $v0, $a0, 0  # retorna a fun��o em v0
  jr $ra  # rotorna ao fluxo normal


imprime_string:						#Recebe a string a ser lida em $a0
    addi $v0, $0, 4						#Chama a fun��o imprimir string
    syscall						#Executa a fun��o
    jr $ra						#Retorna pra quem chamou o procedimento
    
fim: # finaliza o codigo
  addi $v0, $0,  10   # Armazena o c�digo da syscall para finalizar o codigo
  syscall
