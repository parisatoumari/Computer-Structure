#include <xc.h>
#include "configbits.c"
    
.global main 
.ent main
main:

la $8, ANSELB
sw $0, 0($8)  
    
la $8, TRISB
ori $9, $0, 0x0000
sw $9, 0($8)
    
la $11, LATB
 
addi $10, $0, 0x013f
addi $1, $0, 0x0106
addi $2, $0, 0x015b
addi $3, $0, 0x014f
addi $4, $0, 0x0166
addi $5, $0, 0x016d
addi $6, $0, 0x017d
addi $7, $0, 0x0107
addi $8, $0, 0x017f
addi $9, $0, 0x0167 
//look up table for displaying 0-9 in a 7-seg
        
    
addi $12, $0, 0
lui $13, 0x001f
ori $13, $13, 0xffff
    
loop1:    
    
sw $9, 0($11)   
//displaying number "9" in the 7-seg
addi $12, $12, 1
slt $14, $12, $13
bne $14, $0, loop1 
//repeat this loop until the number can be seen clearly on the 7-seg
   
addi $12, $0, 0 
//make the counter zero
loop2:    
//go to the next number
sw $9, 0($11)
addi $12, $12, 1
slt $14, $12, $13
bne $14, $0, loop2     
    
addi $12, $0, 0       
loop3:    
sw $1, 0($11)
addi $12, $12, 1
slt $14, $12, $13
bne $14, $0, loop3 

addi $12, $0, 0
loop4:    
sw $10, 0($11)
addi $12, $12, 1
slt $14, $12, $13
bne $14, $0, loop4
    
addi $12, $0, 0
loop5:    
sw $1, 0($11)
addi $12, $12, 1
slt $14, $12, $13
bne $14, $0, loop5 
    
addi $12, $0, 0
loop6:    
sw $6, 0($11)
addi $12, $12, 1
slt $14, $12, $13
bne $14, $0, loop6   
    
addi $12, $0, 0
loop7:    
sw $10, 0($11)
addi $12, $12, 1
slt $14, $12, $13
bne $14, $0, loop7 
    
addi $12, $0, 0
loop8:  
sw $8, 0($11)
addi $12, $12, 1
slt $14, $12, $13
bne $14, $0, loop8     

j loop1
//repeat this showing of numbers indefinitely
    
.end main