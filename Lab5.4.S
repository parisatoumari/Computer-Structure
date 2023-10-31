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
//defining the 7-seg patterns without k
    
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
//defining the real numbers
 
addi $12, $0, -1
addi $13, $0, 10 
    
mainLoop:
//mainloop which shows each state of whole 7-segs 
    
addi $12, $12, 1  
//the number that is going to be shown
add $17, $0, $12
//the copy of number
addi $18, $0, 0x0100
//the first k for numbers
addi $30, $0, 4 
//counter counting number of divisions by 10
    
for:  
//for shows each one digit (one 7-seg) 
    
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
//make sure that all the ks are 0
       
divu $17, $13
mfhi $14
mflo $15 
//devide the main number by 10
    
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
//decide which number is the remainder that is the first digit of the main number 
       
continue: 
    
addi $16, $0, 0x3fff
delay1: 
addi $16, $16, -1
bne $16, $0, delay1
//delay between two digits which should be unnoticeable
    
add $17, $0, $15  
//move the quotidient of the last division to the number that is going to be divided again
sll $18, $18, 1 
//shift the k in order to show the next digit of the main number
 
bne $30, $0, for
//if the main number is not finished repeat dividing
    
addi $16, $0, 0x1fff
delay2: 
addi $16, $16, -1
bne $16, $0, delay2  
//delay between two states of the whole 7-segs 
     
j mainLoop    

zeroo:
    add $10, $10, $18
    //add the k
    sw $10, 0($11)
    j continue
    //show the number decided and go back to the mainloop
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