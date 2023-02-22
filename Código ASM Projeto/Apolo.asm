.eqv rcvr_ctrl 0xffff0000
.eqv rcvr_data 0xffff0004
.eqv trsmttr_ctrl 0xffff0008
.eqv trsmttr_data 0xffff000c

.data
	str_padrao: .asciiz "VIA-shell>> "
	barra_n: .byte 10

.text
main:
	la $a1, str_padrao
	jal shell_str_loop
	j rcvr_loop
	
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
    lb $t0, barra_n
    beq $a0, $t0, quebra_linha
    j trsmttr_loop	

quebra_linha:
	lw $t0, trsmttr_ctrl					
    andi $t1, $t0, 1               		
    beq $t1, $zero, quebra_linha
	lb $t0, barra_n
	sb $t0, trsmttr_data
	j main				

trsmttr_loop:
    lw $t0, trsmttr_ctrl					
    andi $t1, $t0, 1               		
    beq $t1, $zero, trsmttr_loop	
    sb $a0, trsmttr_data
    j rcvr_loop						

