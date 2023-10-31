#include <xc.h>
#include "configbits.c"
.global main 
.ent main
main:

la $8, ANSELB
sw $0, 0($8)
    
la $8, TRISB
ori $9, $0, 0x00ff
sw $9, 0($8)
    
la $10, PORTB
la $11, LATB
    
loop:

lw $8, 0($10)

andi $12, $8, 0x000f
andi $13, $8, 0x00f0
srl $13, $13, 4
    
multu $12, $13
//multiply the numbers    
mflo $14    
//we assure that the result of multiplication of 2 BCD numbers won't overrun 9*9=81 
//which won't need more than 32 bits therefore we are sure that the hi register is all 0 and we just move the lo bits
 
addi $16, $0, -1 
//define a counter    
L:     
addi $16, $16, 1  
//add up the counter in each loop    
    
addi $15, $14, -10
//reduce the result by 10     
sltu $1, $14, $15
bne $1, $0, enough
//check if we achieved a one digit number or not    

add $14, $15, $0 
//if the number is not one digit yet change the result and repeat the actions above    
j L
    
enough:
sll $16, $16, 4
add $14, $14, $16
//display the number of tens($16) in tens column and the rest in ones column
    
sll $14, $14, 8
//transfer the final result to the output parts
sw $14, 0($11)
    
j loop
    
.end main