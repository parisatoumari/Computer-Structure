lui $t0,0x1001
ori $t0,$t0,0x0000
lw $a0, 0($t0)
#loading register

jal fib
#calling the function

sw $v0, 4($t0)
#storing the result

j done
#end

fib:

addi $sp, $sp, -4
sw $ra, 0($sp)
#make room in the stack and store $ra return address

addi $k0, $zero, 2
sltu $k0, $k0, $a0
bne $k0, $zero, else
#check the recursive condition and goto else if not met 

addi $v0, $v0, 1
#if a0 is 1 or 2 (less than or equal with k0) add v0 by 1 which is the fibonacci's first and second amount

addi $sp, $sp, 4
#restore stack
jr $ra 
#jump back to return address

else:

addi $sp, $sp, -4
sw $a0, 0($sp)
#make room and store a0 (the number working on it)

addi $a0, $a0, -1
#calculating fibonacci of a0-1
jal fib
#jump to fib function

lw $a0, 0($sp)
addi $sp, $sp, 4
#load the previous a0 and restore stack

addi $a0, $a0, -2
#calculating fibonacci of a0-2
jal fib
#jump to fib function

lw $ra, 0($sp)
addi $sp, $sp, 4
#load the return register and restore stack
jr $ra
#jump to the return address

done: