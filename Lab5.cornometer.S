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
 
addi $10, $0, 0x003f
addi $1, $0, 0x0006
addi $2, $0, 0x005b
addi $3, $0, 0x004f
addi $4, $0, 0x0066
addi $5, $0, 0x006d
addi $6, $0, 0x007d
addi $7, $0, 0x0007
addi $8, $0, 0x007f
addi $9, $0, 0x0067
    
addi $20, $0, 0
addi $21, $0, 1
addi $22, $0, 2
addi $23, $0, 3
addi $24, $0, 4
addi $25, $0, 5
addi $26, $0, 6
addi $27, $0, 7
addi $28, $0, 8
addi $29, $0, 9   
 
addi $12, $0, -1
addi $13, $0, 10
    
mainLoop:

add $19, $12, $0
//copy of number
addi $31, $0, 100 
divu $19, $31
mfhi $31
//seperate the 2 LSBs of the number
    
addi $19, $0, 59      
bne $31, $19, minuete
//if they have reached 59 ignore the rest of the numbers and add 41 to the main number so that the next number would be ##00
 
addi $12, $12, 40
minuete:
addi $12, $12, 1 

add $19, $12, $0
addi $31, $0, 100 
divu $19, $31   
mflo $31  
//seperate the 2 MSBs of the number
    
addi $19, $0, 60    
bne $31, $19, hour
//if they have reached 60 restart the whole cornometer and show 0000
 
addi $12, $0, 0
hour:   
 
add $17, $0, $12
addi $18, $0, 0x0100 
addi $30, $0, 4       
    
for:  
    
addi $30, $30, -1    
    
andi $10, $10, 0x00ff
andi $1, $1, 0x00ff
andi $2, $2, 0x00ff
andi $3, $3, 0x00ff
andi $4, $4, 0x00ff
andi $5, $5, 0x00ff
andi $6, $6, 0x00ff
andi $7, $7, 0x00ff
andi $8, $8, 0x00ff
andi $9, $9, 0x00ff   
       
divu $17, $13
mfhi $14
mflo $15    
    
beq $14, $20, zeroo
beq $14, $21, one
beq $14, $22, two
beq $14, $23, three
beq $14, $24, four
beq $14, $25, five
beq $14, $26, six
beq $14, $27, seven
beq $14, $28, eight
beq $14, $29, nine
       
continue: 
    
addi $16, $0, 0x3fff
delay1: 
addi $16, $16, -1
bne $16, $0, delay1
    
add $17, $0, $15  
sll $18, $18, 1 
 
bne $30, $0, for
    
addi $16, $0, 0x1fff
delay2: 
addi $16, $16, -1
bne $16, $0, delay2   
     
j mainLoop    

zeroo:
    add $10, $10, $18
    sw $10, 0($11)
    j continue
one:
    add $1, $1, $18
    sw $1, 0($11)
    j continue
two:
    add $2, $2, $18
    sw $2, 0($11)
    j continue
three:
    add $3, $3, $18
    sw $3, 0($11)
    j continue
four:
    add $4, $4, $18
    sw $4, 0($11)
    j continue
five:
    add $5, $5, $18
    sw $5, 0($11)
    j continue
six:
    add $6, $6, $18
    sw $6, 0($11)
    j continue
seven:
    add $7, $7, $18
    sw $7, 0($11)
    j continue
eight:
    add $8, $8, $18
    sw $8, 0($11)
    j continue
nine:
    add $9, $9, $18
    sw $9, 0($11)
    j continue
    
.end main  