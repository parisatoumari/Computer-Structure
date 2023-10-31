#include <xc.h>
#include "configbits.c"
.global main 
.ent main
main:

la $8, ANSELA
sw $0, 0($8)

la $8, ANSELB
sw $0, 0($8)
    
la $8, TRISA
ori $9, $0, 0x00ff
sw $9, 0($8)
    
la $8, TRISB
sw $0, 0($8)
    
la $10, PORTA
la $11, LATB
    
add $12, $0, $0
add $16, $0, $0
addi $17, $0, 0x00c8
//set the primary value of some registers(0, 0, 200) 
    
loop:
   
lw $8, 0($10)
lw $14, 0($11)
//load the numbers represent inputs and outputs
    
//andi $8, $8, 0x0001

slt $13, $12, $8
//if the current value of input is bigger than its previous value (now is 1 and previously it was 0) (the input is pressed) ...    

addi $16, $16, 1
//save the number of times the loop is run until here from last change of LED   

beq $13, $0, mainLoop   
//if the input is not pressed go to mainLoop else continue    

slt $18, $16, $17
bne $18, $0, mainLoop    
//also if the number of constant 1 is below 200 go to mainLoop because its not a real press     
    
slt $15, $0, $14
bne $15, $0, next
//if the current state of LED is 1 goto next to turn if off 

sll $8, $8, 8      
sw $8, 0($11) 
add $16, $0, $0     
j mainLoop
//if the current state of LED is 0 turn it on    
    
next:
sll $8, $8, 8      
sw $0, 0($11) 
add $16, $0, $0    
//turn off the LED     
    
mainLoop:
add $12, $0, $8  
//do nothing and save the current state of input as its previous state in the next loop     
    
j loop 
.end main