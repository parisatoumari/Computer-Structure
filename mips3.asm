lui $t0,0x1001
ori $t0,$t0,0x0000

lui $t1,0x1001
ori $t1,$t1,0x0004

lw $t2, 0($t0)
lw $t3, 0($t1)
#loading registers


lui $at,0x8000
ori $at,$at,0x0000
#defining a register as iterator

and $t6, $at, $t2
and $t7, $at, $t3
#set apart the sign bit

sltu $k1, $t6, $t7
bne $k1, $zero, end1 
#if t3 is negative and t2 is positive go to end1

sltu $k1, $t7, $t6
bne $k1, $zero, end2
#if t3 is positive and t2 is negative go to end2

beq $t2, $t3, end1
#if t2 and t3 are equal go to end1(no difference which end)

#t2 and t3 have same sign and are not equal:
loop:

srl $at, $at, 1
#shifting the itirator 

and $t4, $at, $t2
and $t5, $at, $t3
beq $t4, $t5, loop
#set apart 1 bit of each number per loop and compare them
#if equal, repeat until reach an unequal pair of bits
#else continue:

sltu $k0, $t4, $t5
#compare the bits
beq $k0, $zero, if
#if t4 is larger than t5 -> goto if
bne $k0, $zero, else
#if t5 is larger than t4 -> goto else

if:
bne $t6, $zero, end2
beq $t6, $zero, end1
#if both numbers were negative goto end2
#if both numbers were positive goto end1

else:
bne $t6, $zero, end1
beq $t6, $zero, end2
#if both numbers were negative goto end1
#if both numbers were positive goto end2


end1:
sw $t2, 0($t0)
sw $t3, 0($t1)
j done
#store the numbers as if t2 is larger than t3

end2:
sw $t3, 0($t0)
sw $t2, 0($t1)
j done
#store the numbers as if t3 is larger than t2

done:
#end