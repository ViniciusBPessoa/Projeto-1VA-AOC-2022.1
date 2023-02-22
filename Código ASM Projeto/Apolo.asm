.eqv rcvr_ctrl 0xffff0000
.eqv rcvr_data 0xffff0004
.eqv trsmttr_ctrl 0xffff0008
.eqv trsmttr_data 0xffff000c

.data
	str_padrao: .asciiz "VIA-shell>> "
	barra_n: .byte 10
	terminal_cmd: .space 100
	
	cmd_ad_m: .asciiz "ad_morador-"
	cmd_rm_m: .asciiz "rm_morador-"
	cmd_ad_a: .asciiz "ad_auto-"
	cmd_rm_a: .asciiz "rm_auto-"
	cmd_lp_ap: .asciiz "limpar_ap-"
	cmd_if_ap: .asciiz "info_ap-"
	cmd_if_g: .asciiz "info_geral"
	cmd_s: .asciiz "salvar"
	cmd_r: .asciiz "recarregar"
	cmd_f: .asciiz "formatar"
	msg_c_v: .asciiz "Comando Valido"
	msg_c_i: .asciiz "Comando Invalido"

.text
main:
	la $s0, msg_c_v
	la $s1, msg_c_i	
	la $a1, str_padrao
	jal shell_str_loop
	la $a1, terminal_cmd
	j rcvr_loop
	
compara_str:
	lb $t0, 0($a0)
	lb $t1, 0($a1)
	bne $t0, $t1, str_diferente
	beq $t0, $0, filtro_str0
	beq $t1, $0, filtro_str1
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	j compara_str

str_diferente:
	addi $v0, $0, 1
	jr $ra

str_igual:
	move $v0, $0
	jr $ra

filtro_str0:
	beq $t1, $0, str_igual
	j str_diferente
	
filtro_str1:
	beq $t0, $0, str_igual
	j str_diferente
	
	
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
					

