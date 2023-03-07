# Projeto 1 VA Arquitetura e Organização de Computadores - 2022.1
# Alunos: Vinícius Bezerra, Irlan Farias, Apolo Albuquerque, joão vitor castro
# Descrição do arquivo: Código .asm da questão 5

.eqv rec_ctrl 0xffff0000
.eqv rec_data 0xffff0004
.eqv tran_ctrl 0xffff0008
.eqv tran_data 0xffff000c

.text
receiver_loop:	
    lw $t0, rec_ctrl			# Armazena o valor contido no endereço representado por "rec_ctrl" em t0           
    
    andi $t1, $t0, 1            	# Faz a operação AND entre o valor contido no reg t0 e 1 a fim de isolar o último bit (bit "pronto")
    beq $t1, $zero, receiver_loop	# Caso seja 0, não está pronto: o caractere ainda não foi completamente lido no Receiver Data
    
    lb $a0, rec_data			# Caso seja 1, está pronto: aqui o caractere escrito no terminal é lido no Receiver Data
    
    j transmitter_loop			# Jump para o loop do Transmitter	

transmitter_loop:
    lw $t0, tran_ctrl			# Armazena o valor contido no endereço representado por "tran_ctrl" em t0 
    
    andi $t1, $t0, 1               	# Faz a operação AND entre o valor contido no reg t0 e 1 a fim de isolar o último bit (bit "pronto")
    beq $t1, $zero, transmitter_loop   	# Caso seja 0, não está pronto: o caractere ainda não foi completamente escrito no Transmitter Data
    
    sb $a0, tran_data			# Caso seja 1, está pronto: aqui o caractere lido no terminal é escrito no Transmitter Data
    
    j receiver_loop			# Jump para o loop do Receiver (para ler o próximo caractere escrito no terminal)
