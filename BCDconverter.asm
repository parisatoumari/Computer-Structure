lui $t0, 0x1001
ori $t0, $t0, 0x0000
lw $a0, 0($t0)
#loading register

jal BCDconverter
#calling the function

sw $v0, 4($t0)
#storing the result

j exit
#end

BCDconverter :

lui $s0, 0xf000
ori $s0, $s0, 0x0000
#defining an iterator

lui $s1, 0x0000
ori $s1, $s1, 0x000a
#set the amount of a register to 10

loop:

beq $s0, $zero, done
#if the iterator is 0 end

and $t1, $s0, $a0
#set apart one bit of number per loop

shift:

beq $t1, $zero, enough
#if the bit was 0 don't shift

andi $k1, $t1, 0x0000000f
sltu $k1, $zero, $k1
bne $k1, $zero, enough
srl $t1, $t1, 4
j shift
#if the LSB is 0 shift until it is not

enough: 

multu $v0, $s1
mflo $v0
add $v0, $v0, $t1
#multiply the previous result by 10 and add the new amount(we assure that it won't be more than 32 bits)

srl $s0, $s0, 4
#shift the iterator

j loop

done: 

jr $ra
#jump back to callee

exit: