
.text
li $t9, 0
.globl initialize
initialize:
addi $sp, $sp, -32
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s4, 16($sp)
sw $s5, 20($sp)
sw $s6, 24($sp)
sw $s7, 28($sp)

add $s0, $a0, $0 #$s0 = filename
add $s1, $a1, $0 #s1 = buffer

#open file
add $a0, $0, $s0
li $a1, 0
li $a2, 0
li $v0, 13
syscall 
bltz $v0, initialize_error

#read first char
add $a0, $v0, $0
add $a1, $s1, $0
li $a2, 1
li $v0, 14
syscall
blez $v0, reset_buffer

li $s2, '0'
li $s3, '9'
li $s4, 10 #/n
li $s5, 13 #/r
add $t0, $0, $s1

lb $t1, 0($t0)
bgt $t1, $s3, reset_buffer
blt $t1, $s2, reset_buffer
addi $s6, $t1, -48 #$s6 = rows
sb $s6, 0($t0)

addi $t0, $t0, 4
add $a1, $t0, $0
li $v0, 14
syscall
blez $v0, reset_buffer

lb $t1, 0($t0)
beq $t1, $s5, initialize_carriage
bne $t1, $s4, reset_buffer
j initialize_column

initialize_carriage:
li $v0, 14
syscall
blez $v0, reset_buffer
lb $t1, 0($t0)
bne $t1, $s4, reset_buffer

initialize_column:
li $v0, 14
syscall
blez $v0, reset_buffer
lb $t1, 0($t0)
bgt $t1, $s3, reset_buffer
blt $t1, $s2, reset_buffer
addi $s7, $t1, -48 #$s7 = columns
sb $s7, 0($t0)

addi $t0, $t0, 4
add $a1, $t0, $0
li $v0, 14
syscall
blez $v0, reset_buffer
lb $t1, 0($t0)
beq $t1, $s5, initialize_carriage2
bne $t1, $s4, reset_buffer
j row_column_exit

initialize_carriage2:
li $v0, 14
syscall
blez $v0, reset_buffer
lb $t1, 0($t0)
bne $t1, $s4, reset_buffer

row_column_exit:
li $t2, 1 #row counter
li $t3, 0 #column counter
li $t4, 332
add $t4, $t4, $s1
blez $v0, reset_buffer

initialize_loop:
mul $t5, $t2, $t3
add $a1, $t0, $0
li $v0, 14
syscall
beqz $v0, initialize_loop_exit
lb $t1, 0($t0)
beq $t1, $s5, initialize_loop_newline_windows
beq $t1, $s4, initialize_loop_newline_unix
j initialize_increment

initialize_loop_newline_windows:
li $v0, 14
syscall
li $v0, 14
syscall
beqz $v0, initialize_loop_exit
addi $t2, $t2, 1
blt $t3, $s7, reset_buffer
li $t3, 0
j initialize_increment

initialize_loop_newline_unix:
li $v0, 14
syscall
beqz $v0, initialize_loop_exit
addi $t2, $t2, 1
blt $t3, $s7, reset_buffer
li $t3, 0

initialize_increment:
lb $t1, 0($t0)
bgt $t2, $s6, reset_buffer
bgt $t1, $s3, reset_buffer
blt $t1, $s2, reset_buffer
addi $t1, $t1, -48
sb $t1, 0($t0)
add $a1, $t0, $0
addi $t0, $t0, 4
addi $t3, $t3, 1
bge $t0, $t4, initialize_successful
j initialize_loop

reset_buffer:
li $t0, 83
li $t1, 0
add $t2, $s1, $0

reset_loop:
beq $t0, $t1, initialize_error
sw $0, 0($t2)
addi $t2, $t2, 4
addi $t1, $t1, 1
j reset_loop

initialize_error:
li $v0, -1
j initialize_exit

initialize_loop_exit:
bne $t2, $s6, reset_buffer
bne $t3, $s7, reset_buffer
sb $0, 0($t0)

initialize_successful:
li $v0, 1

initialize_exit:
lw $s0, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s4, 16($sp)
lw $s5, 20($sp)
lw $s6, 24($sp)
lw $s7, 28($sp)
addi $sp, $sp, 32
 jr $ra

.globl write_file
write_file:
addi $sp, $sp, -12
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)

add $s0, $a0, $0 #$s0 = filename
add $s1, $a1, $0 #s1 = buffer

#open file
add $a0, $0, $s0
li $a1, 1
li $a2, 0
li $v0, 13
syscall
add $s2, $0, $v0 #$s2 = file descriptor

#write number of rows
addi $t0, $s1, 0
lb $t1, 0($t0)
add $t2, $t1, $0
addi $t1, $t1, 48
sb $t1, 0 ($t0)
add $a0, $0, $s2
add $a1, $t0, $0
li $a2, 1
li $v0, 15
syscall
#new line after row
li $t1, 10
sb $t1, 0 ($t0)
li $v0, 15
syscall
#write number of columns
addi $t0, $t0, 4
lb $t1, 0($t0)
add $t3, $t1, $0 #$t3 = num of columns
addi $t1, $t1, 48
sb $t1, 0 ($t0)
add $a1, $t0, $0
li $v0, 15
syscall
#new line after column
li $t1, 10
sb $t1, 0 ($t0)
li $v0, 15
syscall

mul $t2, $t2, $t3 #$t2 = num of values
li $t4, 0 #$t4 = counter
addi $t0, $t0, 4

writing_loop:
beq $t2, $t4, writing_exit
lb $t1, 0($t0)
addi $t1, $t1, 48
sb $t1, 0 ($t0)
add $a1, $t0, $0
li $v0, 15
syscall
addi $t4, $t4, 1
div $t4, $t3
mfhi $t5
bnez $t5, continue_writing_loop
li $t1, 10
sb $t1, 0 ($t0)
li $v0, 15
syscall
continue_writing_loop:
addi $t0, $t0, 4
j writing_loop

writing_exit:
li $v0, 16
add $a0, $s2, $0
syscall
lw $s0, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
addi $sp, $sp, 12
 jr $ra
 
.globl rotate_clkws_90
rotate_clkws_90:
#switching num of rows and columns
lb $t0, 0($a0) #$t0 = original row
lb $t1, 4($a0) #$t1 = original columns
sb $t1, 0($a0)
sb $t0, 4($a0)

mul $t3, $t0, $t1 #$t3 = num of elements
sub $sp, $sp, $t3
add $fp, $sp, $0
li $t4, 0 #$t4 = row counter
li $t5, 0 #$t5 = column counter

rotate_90_loop:
beq $t5, $t1, rotate_90_exit
addi $t5, $t5, 1
li $t4, 0
rotate_90_storing:
beq $t0, $t4, rotate_90_storing_exit
addi $t6, $t5, -1
mul $t6, $t6, $t0
add $t6, $t6, $t4
add $sp, $t6, $fp
sub $t6, $t0, $t4
addi $t6,  $t6, -1
mul $t6, $t6, $t1
add $t6, $t6, $t5
addi $t6, $t6, -1
sll $t6, $t6, 2
addi $t6, $t6, 8
add $t7, $t6, $a0
lb $t6, 0($t7)
sb $t6, 0($sp)
addi $t4, $t4, 1
j rotate_90_storing
rotate_90_storing_exit:
j rotate_90_loop

rotate_90_exit:
add $sp, $fp, $0
add $t7, $a0, $0
addi $t7, $t7, 8
li $t2, 0
rotate_90_buffer:
beq $t2, $t3, rotate_90_write
lb $t4, 0($sp)
sb $t4, 0($t7)
addi $t2, $t2, 1
addi $t7, $t7, 4
addi $sp, $sp, 1
j rotate_90_buffer

rotate_90_write:
add $sp, $fp, $0
add $sp, $t3, $sp
li $t7, 1
beq $t9, $t7, rotate_90_finish
add $t7, $a0, $0
add $a0, $a1, $0
add $a1, $t7, $0
addi $sp, $sp, -4
sw $ra, 0($sp)
jal write_file
lw $ra, 0($sp)
addi $sp, $sp, 4

rotate_90_finish:
li $t9, 0
 jr $ra

.globl rotate_clkws_180
rotate_clkws_180:
addi $sp, $sp, -12
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)

add $s0, $a0, $0 #$t8 = buffer
add $s1, $a1, $0 #$t9 = filename

li $t9, 1
jal rotate_clkws_90

li $t9, 0
add $a0, $s0, $0
add $a1, $s1, $0
jal rotate_clkws_90

lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
addi $sp, $sp, 12
 jr $ra
 
.globl rotate_clkws_270
rotate_clkws_270:
addi $sp, $sp, -12
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)

add $s0, $a0, $0 #$t8 = buffer
add $s1, $a1, $0 #$t9 = filename

li $t9, 1
jal rotate_clkws_90

li $t9, 1
add $a0, $s0, $0
add $a1, $s1, $0
jal rotate_clkws_90

li $t9, 0
add $a0, $s0, $0
add $a1, $s1, $0
jal rotate_clkws_90

lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
addi $sp, $sp, 12
 jr $ra

.globl mirror
mirror:
addi $sp, $sp, -4
sw $ra, 0($sp)

lb $t0, 0($a0) #$t0 = rows
lb $t1, 4($a0) #$t1 = columns

li $t2, 0 #$t2 = row counter
addi $t8, $a0, 8 #t8 = beginning of elements

mirror_row_loop:
beq $t2, $t0, mirror_loop_exit
mul $t3, $t2, $t1 #first element of specific row
sll $t3, $t3, 2
add $t3, $t8, $t3 #first element of the row
addi $t4, $t1, -1
sll $t4, $t4, 2
add $t4, $t3, $t4 #last element of the row
mirror_swapping:
bge $t3, $t4, mirror_swapping_exit
lb $t5, 0($t3)
lb $t6, 0($t4)
add $t7, $t5, $0
sb $t6, 0($t3)
sb $t7, 0($t4)
addi $t3, $t3, 4
addi $t4, $t4, -4
j mirror_swapping
mirror_swapping_exit:
addi $t2, $t2, 1
j mirror_row_loop

mirror_loop_exit:
add $t0, $a0, $0
add $a0, $a1, $0
add $a1, $t0, $0 
jal write_file
lw $ra, 0($sp)
addi $sp, $sp, 4
 jr $ra

.globl duplicate
duplicate:
addi $sp, $sp, -12
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)

lb $s0, 0($a0) #$s0 = rows
lb $s1, 4($a0) #$s1 = columns
addi $s2, $a0, 8 #$s2 = beginning of the elements
li $t1, 0 #$t1 = row counter
li $t8, 10

duplicate_loop:
beq $t1, $s0, duplicates_loop_exit
mul $t2, $t1, $s1 #first element of specific row
sll $t2, $t2, 2
add $t2, $s2, $t2
addi $t3, $t1, 1 #$t3 = second row counter

row_comparer:
beq $t3, $s0, comparer_exit
beq $t3, $t1, comparer_end
mul $t4, $t3, $s1
sll $t4, $t4, 2
add $t4, $t4, $s2
li $t5,  0 #$t5 = column counter
add $t0, $t2, $0 #duplicate 

element_comparer:
beq $t5, $s1, found
lb $t6, 0($t0)
lb $t7, 0($t4)
bne $t6, $t7, comparer_end
addi $t0, $t0, 4
addi $t4, $t4, 4
addi $t5, $t5, 1
j element_comparer

found:
bgt $t3, $t8, comparer_end
add $t8, $t3, $0

comparer_end:
addi $t3, $t3, 1 
j row_comparer

comparer_exit:
addi $t1, $t1, 1
j duplicate_loop

duplicates_loop_exit:
li $t0, 10
bne $t8, $t0, duplicates_found

no_duplicates:
li $v0, -1
li $v1, 0
j duplicate_exit

duplicates_found:
li $v0, 1
addi $v1, $t8, 1

duplicate_exit:
lw $s0, 0($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
addi $sp, $sp, 12
 jr $ra
