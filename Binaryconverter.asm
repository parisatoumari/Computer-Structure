lui $t0, 0x1001
ori $t0, $t0, 0x0000
lw $a0, 0($t0)
#loading register

jal Binaryconverter
#call the function

sw $v0, 4($t0)
sw $v1, 8($t0)
#storing the results

j exit
#end

Binaryconverter:

lui $s0, 0x0000
ori $s0, $s0, 0x000a
#set a register's amount to 10

add $s2, $zero, $a0
addi $k0, $zero, 1

loop:

sltu $k1, $s2, $k0 
bne $k1, $zero, done
#if the number reached 0 end

divu $a0, $s0
#divide the number by 10

mfhi $s1
mflo $s2
#move the remainder to s1 and the quotidient to s2

srl $v1, $v1, 4
andi $t1, $v0, 0x000f
sll $t1, $t1, 28
add $v1, $v1, $t1
#store the 4 bit LSB of v0 in the MSB of v1 in order not to lose them 

srl $v0, $v0, 4
sll $s1, $s1, 28
add $v0, $v0, $s1
#shift v0 and add the new amount to its MSB

add $a0, $zero, $s2
#move the new amount to a0

j loop

done:

jr $ra
#return to the callee

exit: