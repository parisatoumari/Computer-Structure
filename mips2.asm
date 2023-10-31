lui $t0,0x1001
ori $t0,$t0,0x0000

lui $t1,0x1001
ori $t1,$t1,0x0004

lui $t2,0x1001
ori $t2,$t2,0x0008 

lui $t3,0x1001
ori $t3,$t3,0x000C 

lw $t4, 0($t0)
lw $t5, 0($t1)
lw $t6, 0($t2)
lw $t7, 0($t3)
#loading registers from addresses

multu $t4, $t6
mflo $s0
mfhi $s1

multu $t5, $t6
mflo $s2
mfhi $s3

multu $t4, $t7
mflo $s4
mfhi $s5

multu $t5, $t7
mflo $s6
mfhi $s7
#calculating the partial products

addu $s1, $s1, $s2
addu $s5, $s5, $s6
#adding middle partial products to each other in order to have the correct amounts

addu $a0, $s0, $zero

addu $a1, $s1, $s4

sltu $k0, $a1, $s1
addu $a2, $s3, $s5
addu $a2, $a2, $k0

sltu $k1, $a2, $s3
addu $a3, $s7, $zero
addu $a3, $a3, $k1
#adding partial products considering the shifts and carry of previous columns

lui $v0,0x1001
ori $v0,$v0,0x0010

sw $a0, 0($v0)
sw $a1, 4($v0)
sw $a2, 8($v0)
sw $a3, 12($v0)
#storing the final results