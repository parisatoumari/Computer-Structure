lui $t0,0x1001
ori $t0,$t0,0x0000

lui $t1,0x1001
ori $t1,$t1,0x0004

lui $t2,0x1001
ori $t2,$t2,0x0008 

lui $t3,0x1001
ori $t3,$t3,0x000C 
#assigning addresses

lw $t4, 0($t0)
lw $t5, 0($t1)
lw $t6, 0($t2)
lw $t7, 0($t3)
#loading registers from addresses


addu $t8,$t6,$t4
add $t9,$t7,$t5
sltu $k0,$t8,$t4
add $t9,$t9,$k0
#adding the numbers considering carry

lui $a0,0x1001
ori $a0,$a0,0x0010

lui $a1,0x1001
ori $a1,$a1,0x0014

sw $t8, 0($a0)
sw $t9, 0($a1)
#storing the final variable